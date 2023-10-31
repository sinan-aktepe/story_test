import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:pirimedya_story/pirimedya_story.dart';

List<Story> storyFromJson(String str) => List<Story>.from(json.decode(str).map((x) => Story.fromJson(x)));

List<Story> storyListFromJson(List<dynamic> str) => str.map((e) => Story.fromJson(e)).toList();

String storyToJson(List<Story> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Story implements BaseStory {
  Story(
      {this.siteId,
      this.mainCategory,
      this.title,
      this.publishDate,
      this.expirationDate,
      this.createdDate,
      this.updatedDate,
      this.user,
      this.status,
      this.coverImage,
      this.coverPhotoPath,
      this.order,
      this.stories,
      this.id});

  final String? siteId;
  final MainCategory? mainCategory;
  @override
  final String? title;
  final DateTime? publishDate;
  final DateTime? expirationDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final User? user;
  final int? status;
  final CoverImage? coverImage;
  final String? coverPhotoPath;
  final double? order;
  final List<StoryElement>? stories;
  final String? id;

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      siteId: json["siteId"],
      mainCategory: json["category"] == null ? null : MainCategory.fromJson((json["category"] as List).first),
      title: json["title"],
      publishDate: json["publishDate"] == null ? null : DateTime.parse(json["publishDate"]),
      expirationDate: json["expirationDate"] == null ? null : DateTime.parse(json["expirationDate"]),
      createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
      updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      status: json["status"],
      coverImage: json["coverImage"] == null ? null : CoverImage.fromJson(json["coverImage"]),
      coverPhotoPath: json["coverPhotoPath"],
      order: json["order"],
      stories:
          json["stories"] == null ? [] : List<StoryElement>.from(json["stories"].map((x) => StoryElement.fromJson(x))),
      id: json["id"],
    );
  }

  @override
  String? get coverImagePath =>
      "https://img.piri.net/mnresize/250/-/${coverImage?.crops?.firstWhere((element) => element.type == 'vertical') ?? coverImage?.path}";

  @override
  String get storyId => id ?? "";

  @override
  String get mainCategoryImagePath => "https://assets.gzt.com/gzt/wwwroot/images/categories/${mainCategory?.id}.png";

  @override
  List<BaseStoryItem> get storyItems => stories ?? [];

  @override
  String? get mainCategoryName => mainCategory?.name;

  Map<String, dynamic> toJson() => {
        "siteId": siteId,
        "mainCategory": mainCategory == null ? null : mainCategory!.toJson(),
        "title": title,
        "publishDate": publishDate == null ? null : publishDate!.toIso8601String(),
        "expirationDate": expirationDate == null ? null : expirationDate!.toIso8601String(),
        "createdDate": createdDate == null ? null : createdDate!.toIso8601String(),
        "updatedDate": updatedDate == null ? null : updatedDate!.toIso8601String(),
        "user": user == null ? null : user!.toJson(),
        "status": status,
        "coverPhotoPath": coverPhotoPath,
        "order": order,
        "stories": stories == null ? null : List<dynamic>.from(stories!.map((x) => x.toJson())),
        "id": id,
      };

  @override
  bool get isPinned => false;
}

class CoverImage {
  CoverImage({
    this.crops,
    this.path,
  });

  final List<Crops>? crops;
  final String? path;

  factory CoverImage.fromJson(Map<String, dynamic> json) => CoverImage(
      crops: json["square"] == null ? null : List<Crops>.from(json["crops"].map((x) => Crops.fromJson(x))),
      path: json["path"]);
}

class Crops {
  Crops({
    this.path,
    this.type,
  });

  final String? path;
  final String? type;

  factory Crops.fromJson(Map<String, dynamic> json) => Crops(
        path: json["path"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
      };
}

class MainCategory {
  MainCategory({
    this.id,
    this.name,
    this.color,
    this.linkName,
  });

  final int? id;
  final String? name;
  final String? color;
  final String? linkName;

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(
      id: json["oldId"],
      name: json["name"],
      color: json["color"],
      linkName: json["linkName"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "color": color,
        "linkName": linkName,
      };
}

class StoryElement implements BaseStoryItem {
  StoryElement({
    this.type,
    this.user,
    this.url,
    this.filePath,
    this.content,
    this.description,
    this.createdDate,
    this.isCoverPhoto,
    this.duration,
  });

  @override
  final String? type;
  final User? user;
  @override
  final String? url;
  final String? filePath;
  @override
  final String? content;
  @override
  final String? description;
  @override
  final DateTime? createdDate;
  final bool? isCoverPhoto;

  @override
  final Duration? duration;

  factory StoryElement.fromJson(Map<String, dynamic> json) {
    return StoryElement(
      type: json["type"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      url: json["url"],
      filePath: json["path"] ?? json["filePath"],
      content: json["content"],
      description: json["description"],
      createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
      isCoverPhoto: json["isCoverPhoto"],
      duration: json["duration"] == null ? null : tryParseDuration(json["duration"]),
    );
  }

  @override
  String? get storyFilePath {
    return type == "image" ? "https://img.piri.net/mnresize/600/-/$filePath" : filePath;
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "user": user == null ? null : user!.toJson(),
        "url": url,
        "filePath": filePath,
        "content": content,
        "createdDate": createdDate == null ? null : createdDate!.toIso8601String(),
        "isCoverPhoto": isCoverPhoto,
      };

  @override
  StoryItemType get storyType => type == "image"
      ? StoryItemType.photo
      : type == "embed"
          ? StoryItemType.embed
          : type == "video"
              ? StoryItemType.video
              : StoryItemType.notSupported;
}

class User {
  User({
    this.id,
    this.name,
  });

  final String? id;
  final String? name;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
