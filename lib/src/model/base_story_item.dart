
enum StoryItemType { photo, video ,embed, notSupported}


/// Story grubunun içindeki element
class BaseStoryItem {
  final String? type;
  final String? storyFilePath;
  final String? url;
  final DateTime? createdDate;
  final Duration? duration;
  final String? content;
  final String? description;
  final StoryItemType storyType;

  BaseStoryItem(this.storyType, {this.type, this.storyFilePath ,this.createdDate,this.url,this.content , this.duration,this.description,});

  @override
  toString() => "BaseStoryItem type : $type storyFilePath : $storyFilePath";
}
