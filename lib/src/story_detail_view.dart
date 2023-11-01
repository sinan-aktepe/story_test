import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pirimedya_story/pirimedya_story.dart';
import 'package:pirimedya_story/src/controller/piri_story_contoller.dart';

import 'package/story_view.dart';

class StoryDetailView extends StatefulWidget {
  const StoryDetailView(
      {Key? key,
      required this.storyGroup,
      this.onPageChanged,
      this.cacheNextGroup,
      required this.isScrollingNotifier,
      this.linkPressed,
      this.categoryIconPressed,
      this.loadingWidget,
      this.storyConfig,
      required this.isAutoScroll,
      required this.piriStoryController,
      required this.storyGroupId})
      : super(key: key);

  // final List<BaseStoryItem> storyItems;
  final BaseStory storyGroup;
  final String storyGroupId;
  final Function(bool)? onPageChanged;
  final Function()? cacheNextGroup;
  final PiriStoryController piriStoryController;
  final ValueNotifier<bool> isScrollingNotifier;
  final Function(StoryController, dynamic)? linkPressed;
  final Function(StoryController, dynamic)? categoryIconPressed;
  final Widget? loadingWidget;
  final StoryConfig? storyConfig;
  final ValueNotifier<bool> isAutoScroll;
  @override
  State<StoryDetailView> createState() => _StoryDetailViewState();
}

class _StoryDetailViewState extends State<StoryDetailView> {
  final List<StoryItem> storyItems = [];
  late StoryController _storyController;
  late bool allGroupSeen;
  late int currentPosition;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    _storyController = StoryController();
    currentPosition = widget.piriStoryController.checkLocalStoryElementPosition(widget.storyGroupId);
    allGroupSeen = currentPosition == widget.storyGroup.storyItems.length;
  //  print('_StoryDetailViewState.initState currentPosition ${widget.storyGroup.storyItems}');
    widget.isScrollingNotifier.addListener(progressControlListen);
    initData();
    streamSubscription = _storyController.playbackNotifier.listen(storyControllerListen);

    super.initState();
  }

  void storyControllerListen(PlaybackState value) {
    if (value == PlaybackState.play && widget.isScrollingNotifier.value) {
      _storyController.pause();
    }
  }

  void progressControlListen() {
    if (widget.isScrollingNotifier.value) {
      _storyController.pause();
    } else {
      _storyController.play();
    }
  }

  void initData() {
    //print('_StoryDetailViewState.initData lastSeenElement $lastSeenElement');
    for (int i = 0; i < widget.storyGroup.storyItems.length; i++) {
      BaseStoryItem baseStoryItem = widget.storyGroup.storyItems[i];

      if (baseStoryItem.storyType == StoryItemType.photo) {
        if (widget.storyGroup.storyItems[i].storyFilePath == null) return;
        storyItems.add(StoryItem.pageImage(
            controller: _storyController,
            url: baseStoryItem.storyFilePath!,
            imageFit: BoxFit.cover,
            //caption: widget.storyGroupId,
            position: i,
            loadingWidget: widget.loadingWidget,
            duration: baseStoryItem.duration ?? const Duration(seconds: 6),
            shown: i < currentPosition));
      } else if (baseStoryItem.storyType == StoryItemType.video) {
        if (baseStoryItem.storyFilePath == null) return;
        storyItems.add(StoryItem.pageVideo(baseStoryItem.storyFilePath!,
            imageFit: BoxFit.cover,
            controller: _storyController,
            position: i,
            loadingWidget: widget.loadingWidget,
            duration: baseStoryItem.duration ?? const Duration(seconds: 15),
            shown: i < currentPosition));
      } else if (baseStoryItem.storyType == StoryItemType.embed) {
       // return;
        if (baseStoryItem.content == null) return;
        storyItems.add(StoryItem.embed(baseStoryItem.content!,
            duration: baseStoryItem.duration ?? const Duration(seconds: 6),
            controller: _storyController, position: i, shown: i < currentPosition));
      }
    }
  }

  @override
  void dispose() {
    widget.isScrollingNotifier.removeListener(progressControlListen);
    streamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoryView(
      isAutoScroll:widget.isAutoScroll,
      storyItems: storyItems,
      inline: true,
      storyConfig: widget.storyConfig,
      storyGroup: widget.storyGroup,
      linkPressed: widget.linkPressed,
      categoryIconPressed: widget.categoryIconPressed,
      controller: _storyController,
      // pass controller here too
      // repeat: true,
      // should the stories be slid forever
      onStoryShow: (StoryItem currentStory) {
        cacheManager(context, currentStory.position);
        allGroupSeen = (currentStory.position + 1) == widget.storyGroup.storyItems.length;
        if (currentPosition < currentStory.position) {
          currentPosition = currentStory.position;
          widget.piriStoryController.setSeenStoryElement(widget.storyGroupId, currentStory.position);
        }
        if (allGroupSeen && !widget.storyGroup.isPinned) {
          widget.piriStoryController.setSeenStoryTimestamp(widget.storyGroupId);
          widget.cacheNextGroup?.call();
        }
      },
      onComplete: () {
        widget.onPageChanged?.call(allGroupSeen);
      },

      // Preferrably for inline story view.
    );
  }

  cacheManager(BuildContext context, int position) async {
    int cachePosition = position + 1;
    debugPrint('CacheManager POSITION ${position} cache POSITION $cachePosition');

    if (cachePosition >= widget.storyGroup.storyItems.length) return;

    BaseStoryItem baseStoryItem = widget.storyGroup.storyItems[cachePosition];

    if (baseStoryItem.storyType == StoryItemType.photo && baseStoryItem.storyFilePath != null) {
      //rint(baseStoryItem.url!);
      precacheImage(CachedNetworkImageProvider(baseStoryItem.storyFilePath!), context);
    }
  }
}
