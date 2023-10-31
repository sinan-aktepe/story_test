

class PiriStoryRefreshEvent{

  /// Normalde tüm story widgetları yenileniyor,
  /// Eğer bu parametreyi eklerseniz bu key ile aynı olan
  /// story widgetları yenilenecek,
  final String? key;

  PiriStoryRefreshEvent({this.key});
}