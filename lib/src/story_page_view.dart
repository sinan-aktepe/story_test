import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:pirimedya_story/pirimedya_story.dart';
import 'package:pirimedya_story/src/package/controller/story_controller.dart';
import 'package:pirimedya_story/src/story_detail_view.dart';

import 'controller/piri_story_contoller.dart';
import 'cube_transform/cube_page_view.dart';

class StoryPageView extends StatefulWidget {
  const StoryPageView({
    Key? key,
    this.initialIndex = 0,
    required this.piriStoryController,
    required this.storyData,
    this.linkPressed,
    this.storyConfig,
    this.categoryIconPressed,
    this.loadingWidget,
  }) : super(key: key);

  final int initialIndex;
  final List<BaseStory> storyData;
  final PiriStoryController piriStoryController;
  final Function(StoryController, dynamic)? linkPressed;
  final Function(StoryController, dynamic)? categoryIconPressed;
  final Widget? loadingWidget;
  final StoryConfig? storyConfig;

  @override
  State<StoryPageView> createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> with WidgetsBindingObserver {
  late PageController _pageController;
  Color? statusbarColor;
  late Brightness brightness;

  final ValueNotifier<bool> isAutoScroll = ValueNotifier(false);

  GlobalKey dismissibleKey = GlobalKey();

  bool? _useWhiteStatusBarForeground;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialIndex);
    brightness = SchedulerBinding.instance.window.platformBrightness;
    WidgetsBinding.instance.addObserver(this);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    //changeStatusColor(Colors.black);
    super.initState();
  }

  Future setStatusBarColor() async {
    // await FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    // await FlutterStatusbarcolor.setStatusBarColor(Colors.black);
  }

  void nextGroup() {
    lastStoryControl();
    _pageController.animateToPage((_pageController.page!.toInt() + 1),
        duration: const Duration(milliseconds: 175), curve: Curves.linear);
  }

  void lastStoryControl() {
    //print(" length ${widget.storyData.length}  currentPage ${_pageController.page!.toInt()+1}" );
    if (widget.storyData.length == _pageController.page!.toInt() + 1) {
      Navigator.of(context).pop();
    }
  }

  void previousGroup() {
    _pageController.animateToPage(_pageController.page!.toInt() - 1,
        duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays:SystemUiOverlay.values );
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('story-dismissible-key'),
      onDismissed: (dir) {
        Navigator.of(context).pop();
      },
      movementDuration: const Duration(
        milliseconds: 50,
      ),
      resizeDuration: null,
      direction: DismissDirection.down,
      child: ColoredBox(
        color: Colors.black,
        child: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: Colors.black,
            child: CubePageView.builder(
              controller: _pageController,
              isAutoScroll: isAutoScroll,
              initialIndex: widget.initialIndex,
              itemCount: widget.storyData.length,
              itemBuilder: (context, index, notifier) {
                return CubeWidget(
                    index: index,
                    pageNotifier: notifier,
                    child: StoryDetailView(
                      isAutoScroll: isAutoScroll,
                      storyGroupId: widget.storyData[index].storyId,
                      storyGroup: widget.storyData[index],
                      storyConfig: widget.storyConfig,
                      linkPressed: widget.linkPressed,
                      loadingWidget: widget.loadingWidget,
                      categoryIconPressed: widget.categoryIconPressed,
                      isScrollingNotifier: _pageController.position.isScrollingNotifier,
                      piriStoryController: widget.piriStoryController,
                      onPageChanged: (bool allGroupSeen) {
                        if (allGroupSeen && !widget.storyData[index].isPinned) {
                          widget.piriStoryController.setSeenStoryTimestamp(widget.storyData[index].storyId);
                        }
                        nextGroup();
                      },
                      cacheNextGroup: () {
                        int cachePosition = index + 1;
                        debugPrint('CacheManagerGroup POSITION $index cache POSITION $cachePosition');

                        if (cachePosition >= widget.storyData.length) return;

                        BaseStoryItem baseStoryItem = widget.storyData[cachePosition].storyItems.first;

                        if (baseStoryItem.storyType == StoryItemType.photo && baseStoryItem.storyFilePath != null) {
                          precacheImage(CachedNetworkImageProvider(baseStoryItem.storyFilePath!), context);
                        }
                      },
                    ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
