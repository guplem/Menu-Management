import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/models/result.dart";
import "package:menu_management/theme/theme_custom.dart";

/// A step-by-step cooking guide for a recipe with adjustable servings and timers.
class PlayRecipePage extends StatefulWidget {
  const PlayRecipePage({super.key, required this.recipe});

  final Recipe recipe;

  static void show({required BuildContext context, required Recipe recipe}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PlayRecipePage(recipe: recipe)));
  }

  @override
  State<PlayRecipePage> createState() => _PlayRecipePageState();
}

/// Tracks the state of a running timer for a specific step.
class _StepTimer {
  _StepTimer({required this.stepIndex, required this.totalDuration}) : remainingSeconds = totalDuration.inSeconds;

  final int stepIndex;
  final Duration totalDuration;
  int remainingSeconds;
  Timer? _timer;
  bool _finished = false;

  bool get isRunning => _timer?.isActive ?? false;
  bool get isFinished => _finished;
  Duration get remaining => Duration(seconds: remainingSeconds);

  void start(VoidCallback onTick, VoidCallback onFinished) {
    _timer?.cancel();
    _finished = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        remainingSeconds = 0;
        _finished = true;
        _timer?.cancel();
        onFinished();
      }
      onTick();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _finished = false;
  }

  void dispose() {
    _timer?.cancel();
  }
}

class _PlayRecipePageState extends State<PlayRecipePage> {
  int _currentStep = 0;
  int _servings = 1;
  final List<_StepTimer> _activeTimers = [];
  final Map<int, AudioPlayer> _audioPlayers = {};

  List<Instruction> get _instructions => widget.recipe.instructions;
  int get _totalSteps => _instructions.length;
  Instruction get _currentInstruction => _instructions[_currentStep];

  @override
  void dispose() {
    for (final _StepTimer timer in _activeTimers) {
      timer.dispose();
    }
    for (final AudioPlayer player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  /// Finds all outputs produced by instructions before the given [stepIndex].
  List<_InputInfo> _getInputsForStep(int stepIndex) {
    final Instruction instruction = _instructions[stepIndex];
    final List<_InputInfo> inputs = [];
    for (final String inputId in instruction.inputs) {
      for (int i = 0; i < stepIndex; i++) {
        for (final Result output in _instructions[i].outputs) {
          if (output.id == inputId) {
            inputs.add(_InputInfo(result: output, fromStepIndex: i, fromInstruction: _instructions[i]));
          }
        }
      }
    }
    return inputs;
  }

  /// Returns the active timer for a given step, or null.
  _StepTimer? _timerForStep(int stepIndex) {
    return _activeTimers.where((t) => t.stepIndex == stepIndex && (t.isRunning || t.isFinished)).firstOrNull;
  }

  /// Returns all timers that are running or just finished on steps other than [excludeStep].
  List<_StepTimer> _otherActiveTimers(int excludeStep) {
    return _activeTimers.where((t) => t.stepIndex != excludeStep && (t.isRunning || t.isFinished)).toList();
  }

  void _startTimer(int stepIndex, Duration duration) {
    // Remove any existing timer for this step
    _activeTimers.removeWhere((t) => t.stepIndex == stepIndex);
    final _StepTimer timer = _StepTimer(stepIndex: stepIndex, totalDuration: duration);
    _activeTimers.add(timer);
    timer.start(() => setState(() {}), () {
      setState(() {});
      _showTimerFinishedSnackbar(stepIndex);
    });
    setState(() {});
  }

  void _cancelTimer(int stepIndex) {
    final _StepTimer? timer = _timerForStep(stepIndex);
    timer?.cancel();
    _activeTimers.removeWhere((t) => t.stepIndex == stepIndex);
    _stopNotificationSound(stepIndex);
    setState(() {});
  }

  void _showTimerFinishedSnackbar(int stepIndex) {
    if (!mounted) return;
    _playNotificationSound(stepIndex);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Timer finished for Step ${stepIndex + 1}: ${_instructions[stepIndex].description.first(50) ?? ""}${_instructions[stepIndex].description.length > 50 ? "..." : ""}",
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: "Go to step", onPressed: () => setState(() => _currentStep = stepIndex)),
      ),
    );
  }

  Future<void> _playNotificationSound(int stepIndex) async {
    try {
      // Stop any existing sound for this step
      _stopNotificationSound(stepIndex);

      final AudioPlayer player = AudioPlayer();
      _audioPlayers[stepIndex] = player;

      // Set loop mode
      await player.setReleaseMode(ReleaseMode.loop);

      // Play the local asset sound
      await player.play(AssetSource("sounds/timer.mp3"));
    } catch (e) {
      // Silently fail if sound can't be played
      debugPrint("Failed to play notification sound: $e");
    }
  }

  void _stopNotificationSound(int stepIndex) {
    final AudioPlayer? player = _audioPlayers[stepIndex];
    if (player != null) {
      player.stop();
      player.dispose();
      _audioPlayers.remove(stepIndex);
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      setState(() => _currentStep = step);
    }
  }

  bool get _hasActiveTimers => _activeTimers.any((t) => t.isRunning);

  Future<bool> _onWillPop() async {
    if (!_hasActiveTimers) return true;
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.timer_outlined),
        title: const Text("Active timers"),
        content: const Text("You have active timers running. Leaving this page will cancel all timers. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Stay")),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Leave")),
        ],
      ),
    );
    return leave ?? false;
  }

  String _formatUnit(Unit unit) {
    switch (unit) {
      case Unit.grams:
        return "g";
      case Unit.centiliters:
        return "cl";
      case Unit.pieces:
        return "pcs";
      case Unit.tablespoons:
        return "tbsp";
      case Unit.teaspoons:
        return "tsp";
    }
  }

  String _formatQuantity(Quantity quantity) {
    final double adjusted = quantity.amount * _servings;
    return "${adjusted.toStringWithDecimalsIfNotInteger()} ${_formatUnit(quantity.unit)}";
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final TextTheme textTheme = ThemeCustom.textTheme(context);

    return PopScope(
      canPop: !_hasActiveTimers,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe.name),
          actions: [
            _ServingsSelector(servings: _servings, onChanged: (int value) => setState(() => _servings = value)),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            // Step progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text("Step ${_currentStep + 1} of $_totalSteps", style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(value: (_currentStep + 1) / _totalSteps, borderRadius: ThemeCustom.borderRadiusFullyRounded),
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Padding(
                padding: ThemeCustom.paddingFullPage,
                child: Column(
                  children: [
                    // TOP ROW: Ingredients (left) | Current step instructions (right)
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Ingredients
                          Expanded(child: SingleChildScrollView(child: _buildIngredientsSection(context))),
                          const SizedBox(width: 16),
                          // Right: Current step instructions
                          Expanded(child: SingleChildScrollView(child: _buildCurrentStepSection(context))),
                        ],
                      ),
                    ),
                    const Gap.verticalNewSection(),
                    // BOTTOM ROW: Previous step | Timers | Next step
                    _buildBottomNavigationRow(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context) {
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final TextTheme textTheme = ThemeCustom.textTheme(context);
    final List<_InputInfo> inputs = _getInputsForStep(_currentStep);
    final List<IngredientUsage> ingredients = _currentInstruction.ingredientsUsed;

    if (inputs.isEmpty && ingredients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ingredients", style: textTheme.titleMedium),
        const Gap.vertical(),
        // Inputs from previous steps (visually distinct)
        ...inputs.map((input) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: InkWell(
              borderRadius: ThemeCustom.borderRadiusStandard,
              onTap: () => _showInputDetailDialog(context, input),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: colorScheme.tertiaryContainer, borderRadius: ThemeCustom.borderRadiusStandard),
                child: Row(
                  children: [
                    Icon(Icons.input_rounded, size: 18, color: colorScheme.onTertiaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        input.result.description,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      "from Step ${input.fromStepIndex + 1}",
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          );
        }),
        // Regular ingredients
        ...ingredients.map((IngredientUsage usage) {
          final Ingredient ingredient = IngredientsProvider.instance.get(usage.ingredient);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: ThemeCustom.borderRadiusStandard),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(child: Text(ingredient.name, style: textTheme.bodyMedium)),
                  Text(_formatQuantity(usage.quantity), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCurrentStepSection(BuildContext context) {
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final TextTheme textTheme = ThemeCustom.textTheme(context);
    final List<Result> outputs = _currentInstruction.outputs;

    return OutlinedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: ThemeCustom.borderRadiusFullyRounded),
                child: Center(
                  child: Text(
                    "${_currentStep + 1}",
                    style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text("Instructions", style: textTheme.titleMedium)),
              if (_currentInstruction.workingTimeMinutes > 0)
                Chip(
                  avatar: const Icon(Icons.pan_tool_rounded, size: 16),
                  label: Text("${_currentInstruction.workingTimeMinutes} min"),
                  visualDensity: VisualDensity.compact,
                ),
              if (_currentInstruction.cookingTimeMinutes > 0) ...[
                const SizedBox(width: 6),
                Chip(
                  avatar: const Icon(Icons.local_fire_department_rounded, size: 16),
                  label: Text("${_currentInstruction.cookingTimeMinutes} min"),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const Gap.vertical(),
          Text(_currentInstruction.description, style: textTheme.bodyLarge),
          // Outputs produced by this step
          if (outputs.isNotEmpty) ...[
            const Gap.verticalNewSection(),
            Text("Produces:", style: textTheme.labelLarge?.copyWith(color: colorScheme.tertiary)),
            const SizedBox(height: 4),
            ...outputs.map((Result output) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(Icons.output_rounded, size: 16, color: colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text(output.description, style: textTheme.bodyMedium?.copyWith(color: colorScheme.tertiary)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigationRow(BuildContext context) {
    final TextTheme textTheme = ThemeCustom.textTheme(context);
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final int cookingMinutes = _currentInstruction.cookingTimeMinutes;
    final _StepTimer? currentTimer = _timerForStep(_currentStep);
    final List<_StepTimer> otherTimers = _otherActiveTimers(_currentStep);

    return Row(
      crossAxisAlignment: otherTimers.isEmpty ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        // Left: Previous step
        Expanded(
          child: _currentStep > 0
              ? _StepPreviewCard(
                  label: "Previous",
                  stepIndex: _currentStep - 1,
                  instruction: _instructions[_currentStep - 1],
                  timer: _timerForStep(_currentStep - 1),
                  onTap: () => _goToStep(_currentStep - 1),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        // Center: Timers
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current step timer
              if (cookingMinutes > 0 || currentTimer != null)
                _TimerCard(
                  stepIndex: _currentStep,
                  cookingMinutes: cookingMinutes,
                  timer: currentTimer,
                  onStart: (Duration duration) => _startTimer(_currentStep, duration),
                  onCancel: () => _cancelTimer(_currentStep),
                ),
              // Other active timers
              if (otherTimers.isNotEmpty) ...[
                const Gap.vertical(),
                Text("Other timers", style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                ...otherTimers.map((timer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _TimerCard(
                      stepIndex: timer.stepIndex,
                      cookingMinutes: _instructions[timer.stepIndex].cookingTimeMinutes,
                      timer: timer,
                      onStart: (_) {},
                      onCancel: () => _cancelTimer(timer.stepIndex),
                      compact: true,
                      onTap: () => _goToStep(timer.stepIndex),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right: Next step
        Expanded(
          child: _currentStep < _totalSteps - 1
              ? _StepPreviewCard(
                  label: "Next",
                  stepIndex: _currentStep + 1,
                  instruction: _instructions[_currentStep + 1],
                  timer: _timerForStep(_currentStep + 1),
                  onTap: () => _goToStep(_currentStep + 1),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : FilledCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: colorScheme.onSecondaryContainer, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "Last step completed!",
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondaryContainer),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _showInputDetailDialog(BuildContext context, _InputInfo input) {
    final TextTheme textTheme = ThemeCustom.textTheme(context);
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: Icon(Icons.input_rounded, color: colorScheme.tertiary),
        title: Text(input.result.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Prepared in Step ${input.fromStepIndex + 1}:", style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(input.fromInstruction.description, style: textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Close")),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _goToStep(input.fromStepIndex);
            },
            child: Text("Go to Step ${input.fromStepIndex + 1}"),
          ),
        ],
      ),
    );
  }
}

// --- Supporting widgets ---

/// A selector for the number of servings, displayed in the app bar.
class _ServingsSelector extends StatelessWidget {
  const _ServingsSelector({required this.servings, required this.onChanged});

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final TextTheme textTheme = ThemeCustom.textTheme(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: ThemeCustom.borderRadiusFullyRounded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "$servings ${servings == 1 ? "serving" : "servings"}",
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSecondaryContainer),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: servings < 100 ? () => onChanged(servings + 1) : null,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

/// Displays a timer card with start/cancel controls and remaining time.
class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.stepIndex,
    required this.cookingMinutes,
    required this.timer,
    required this.onStart,
    required this.onCancel,
    this.compact = false,
    this.onTap,
  });

  final int stepIndex;
  final int cookingMinutes;
  final _StepTimer? timer;
  final ValueChanged<Duration> onStart;
  final VoidCallback onCancel;
  final bool compact;
  final VoidCallback? onTap;

  String _formatDuration(Duration d) {
    final int minutes = d.inMinutes;
    final int seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ThemeCustom.colorScheme(context);
    final TextTheme textTheme = ThemeCustom.textTheme(context);

    final bool isRunning = timer?.isRunning ?? false;
    final bool isFinished = timer?.isFinished ?? false;

    return Card(
      color: isFinished
          ? colorScheme.errorContainer
          : isRunning
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: ThemeCustom.borderRadiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeCustom.borderRadiusStandard,
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 14),
          child: Row(
            children: [
              Icon(
                isFinished ? Icons.alarm_on_rounded : Icons.timer_rounded,
                color: isFinished
                    ? colorScheme.onErrorContainer
                    : isRunning
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: compact ? 20 : 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compact)
                      Text(
                        "Step ${stepIndex + 1} timer",
                        style: textTheme.labelSmall?.copyWith(color: isFinished ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer),
                      ),
                    if (isRunning || isFinished)
                      Text(
                        isFinished ? "Timer finished!" : _formatDuration(timer!.remaining),
                        style: (compact ? textTheme.titleSmall : textTheme.titleLarge)?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isFinished ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                        ),
                      )
                    else
                      Text("Start a $cookingMinutes-minute timer", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (!isRunning && !isFinished && cookingMinutes > 0)
                FilledButton.tonal(
                  onPressed: () => onStart(Duration(minutes: cookingMinutes)),
                  child: const Text("Start"),
                ),
              if (isRunning || isFinished) TextButton(onPressed: onCancel, child: Text(isFinished ? "Dismiss" : "Cancel")),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small preview card for previous/next steps.
class _StepPreviewCard extends StatelessWidget {
  const _StepPreviewCard({
    required this.label,
    required this.stepIndex,
    required this.instruction,
    required this.timer,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final int stepIndex;
  final Instruction instruction;
  final _StepTimer? timer;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bool hasTimer = timer != null && (timer!.isRunning || timer!.isFinished);

    return Card(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: ThemeCustom.borderRadiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeCustom.borderRadiusStandard,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    label.startsWith("Previous") || label == "Previous" ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("$label (${stepIndex + 1})", style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                  ),
                  if (hasTimer)
                    Icon(
                      timer!.isFinished ? Icons.alarm_on_rounded : Icons.timer_rounded,
                      size: 16,
                      color: timer!.isFinished ? colorScheme.error : colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                instruction.description,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to track input information for a step.
class _InputInfo {
  const _InputInfo({required this.result, required this.fromStepIndex, required this.fromInstruction});

  final Result result;
  final int fromStepIndex;
  final Instruction fromInstruction;
}
