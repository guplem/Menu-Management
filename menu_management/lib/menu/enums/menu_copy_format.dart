/// The level of detail of the menu text that the export dialog copies.
///
/// Both formats keep the same shape, one line per meal slot. The format only decides how much of
/// each line the text writes, so a reader of one format recognizes the other.
enum MenuCopyFormat {
  /// The dish, the people, and the cook or leftover note of each meal slot.
  simplified,

  /// The simplified line, plus the total time of the recipe of each cook event.
  detailed,
}
