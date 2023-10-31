import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pirimedya_story/src/model/base_story.dart';

class StoryListItem extends StatelessWidget {
  const StoryListItem({
    Key? key,
    this.aspectRatio,
    required this.baseStory,
    // required this.onPressed,
    required this.index,
    required this.isSeen,
  }) : super(key: key);
  final double? aspectRatio;
  final BaseStory baseStory;
//  final Function(int) onPressed;
  final int index;
  final bool isSeen;

  @override
  Widget build(BuildContext context) {
    print('--------- STORY TEST ------------');
    print('aspect ratio: $aspectRatio');
    print('--------- STORY TEST ------------');
    return ClipRRect(
      child: AspectRatio(
        aspectRatio: aspectRatio ?? (1 / 2),
        child: Container(
          margin: const EdgeInsets.all(8),
          foregroundDecoration: BoxDecoration(
            color: isSeen ? Colors.grey.withOpacity(0.25) : null,
            borderRadius: const BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          decoration: BoxDecoration(
            image:
                DecorationImage(image: CachedNetworkImageProvider(baseStory.coverImagePath ?? ""), fit: BoxFit.cover),
            borderRadius: const BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26.withOpacity(0.85)],
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomCircleAvatar(
                    size: 34,
                    backgroundColor: isSeen ? Colors.grey : const Color(0xff5dc3e9),
                    child: CustomCircleAvatar(
                      size: 28,
                      imageUrl: baseStory.mainCategoryImagePath,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                //const Spacer(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 15, right: 10),
                    child: Text(
                      baseStory.title ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({Key? key, this.child, this.backgroundColor, this.margin, this.size, this.imageUrl})
      : super(key: key);
  final Widget? child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final double? size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 12,
      height: size ?? 12,
      margin: margin,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          image: imageUrl != null ? DecorationImage(image: CachedNetworkImageProvider(imageUrl ?? "")) : null),
      child: Center(child: child),
    );
  }
}
