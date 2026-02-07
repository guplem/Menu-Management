/// Provides placeholder "Lorem Ipsum" text for development and testing.
///
/// Useful for quickly filling UI elements with realistic-looking text
/// during prototyping or layout testing.
class LoremIpsum {
  static final List<String> _text = <String>[
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a felis nec arcu imperdiet sagittis. Donec eu lectus nisi. Curabitur eu interdum magna. Aliquam pulvinar ante ultrices elit tristique laoreet. Sed urna magna, fringilla vitae tincidunt id, rhoncus in nulla. Morbi aliquet, est quis fermentum varius, augue orci volutpat nibh, vitae fermentum est velit at erat. Aenean efficitur erat felis, vitae convallis tortor commodo quis. Morbi felis nulla, tristique ac blandit quis, dignissim quis erat. Ut et convallis tellus.",
    "Nam ac dignissim odio, at semper leo. Nullam mollis, leo sit amet sollicitudin laoreet, purus nulla convallis lacus, vitae sodales odio libero non quam. In hendrerit, elit eu vulputate vehicula, lorem ligula dapibus ligula, sed interdum lectus nisi ac metus. Praesent ut feugiat odio. Integer nec lectus quis enim consequat tincidunt eget at arcu. Nam fringilla nunc vel massa congue, id pellentesque magna pulvinar. Cras felis diam, aliquet a posuere sed, sagittis lacinia ipsum. Mauris ut commodo ligula, sed tincidunt leo. Curabitur nec tortor id metus fringilla facilisis. Phasellus vestibulum tellus in mattis vehicula. Sed suscipit suscipit sapien, ut volutpat dui faucibus eget. Pellentesque efficitur nisi in neque convallis, a egestas turpis tincidunt. Duis nec varius dolor, vestibulum dictum nulla. Aliquam porttitor mauris sed eros hendrerit congue. Nunc eu dapibus dolor.",
    "Sed eget tempus risus. Donec egestas velit in purus scelerisque, id convallis nulla accumsan. Nullam sit amet neque sed metus tempus vulputate. Sed interdum auctor ligula eu ullamcorper. Etiam non justo in quam dignissim hendrerit in dictum nunc. Sed sit amet justo diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae;",
    "Nullam nisl risus, tempor sit amet tristique eu, vehicula id enim. Cras a dui a odio lacinia sollicitudin sollicitudin maximus lacus. Pellentesque ultricies condimentum felis lobortis iaculis. Suspendisse potenti. Praesent molestie quam id dignissim volutpat. Cras eu dui ex. Suspendisse sodales nec risus ac facilisis. Phasellus lacinia orci nec augue malesuada luctus. Donec ex magna, laoreet sed pharetra nec, scelerisque id risus. Integer rhoncus interdum vestibulum. Etiam congue elit lectus. Vestibulum vitae dolor venenatis augue egestas blandit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut in mattis mauris, sed maximus risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vestibulum in odio scelerisque interdum.",
    "Integer molestie nibh eu magna ultrices, ut hendrerit justo gravida. Morbi non velit egestas, blandit tortor a, tempor urna. Aliquam dictum nunc sit amet nisi euismod porttitor. Proin dignissim aliquam ante ac iaculis. Suspendisse neque leo, aliquam in varius non, malesuada lacinia leo. Vivamus a nibh auctor, suscipit augue non, efficitur nibh. Integer vestibulum condimentum mauris, id feugiat metus semper vel. Praesent augue velit, fermentum vitae eleifend id, pulvinar vitae erat.",
  ];

  /// Returns the first [quantity] words from the Lorem Ipsum text.
  static String words([int quantity = 5]) {
    return _text[0].split(" ").take(quantity).join(" ");
  }

  /// Returns the first [quantity] sentences from the Lorem Ipsum text.
  static String sentences([int quantity = 1]) {
    List<String> allSentences = _text[0].split(". ");
    return allSentences.take(quantity).join(". ") + (quantity > 0 ? "." : "");
  }

  /// Returns the first [quantity] paragraphs from the Lorem Ipsum text.
  static String paragraphs([int quantity = 1]) {
    return _text.take(quantity).join("\n\n");
  }
}
