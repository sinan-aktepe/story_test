import 'package:pirimedya_story/pirimedya_story.dart';


/// Story grup
class BaseStory {
  final String? title;
  final String? mainCategoryName;
  final String storyId;
  final String mainCategoryImagePath;
  final String? coverImagePath;
  final bool isPinned;
  final List<BaseStoryItem> storyItems;

  BaseStory({
    this.title,
    required this.mainCategoryImagePath,
    this.coverImagePath,
    this.mainCategoryName,
    required this.isPinned ,
    required this.storyId,
    required this.storyItems,
  });

  @override
  toString() => "BaseStory storyId : $storyId";
}
