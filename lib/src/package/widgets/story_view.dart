import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:pirimedya_story/pirimedya_story.dart';
import 'package:pirimedya_story/src/package/widgets/story_embed.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../controller/story_controller.dart';
import '../utils.dart';
import 'story_image.dart';
import 'story_video.dart';

/// Indicates where the progress indicators should be placed.
enum ProgressPosition { top, bottom }

/// This is used to specify the height of the progress indicator. Inline stories
/// should use [small]
enum IndicatorHeight { small, large }

class Information {
  //title
  //katergory;
}

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  //final BaseStoryItem baseStoryItem;
  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  final int position;

  /// The page content
  final Widget view;

  final Widget? loadingWidget;

  StoryItem(
    this.view, {
    required this.duration,
    this.loadingWidget,
    this.shown = false,
    required this.position,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required int position,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage({
    required String url,
    required int position,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    Widget? loadingWidget,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        child: Stack(
          children: <Widget>[
            StoryImage2.url(
              url,
              controller: controller,
              loadingWidget: loadingWidget,
              fit: imageFit,
              requestHeaders: requestHeaders,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({
    required String url,
    required int position,
    Text? caption,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.cover,
    Map<String, dynamic>? requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      ClipRRect(
        key: key,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      child: caption ?? const SizedBox(),
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    String url, {
    required StoryController controller,
    required int position,
    Key? key,
    Duration? duration,
    Widget? loadingWidget,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              StoryVideo.url(
                url,
                controller: controller,
                loadingWidget: loadingWidget,
                requestHeaders: requestHeaders,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        position: position,
        duration: duration ?? const Duration(seconds: 10));
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    required int position,
    bool shown = false,
    Duration? duration,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: imageFit,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        position: position,
        duration: duration ?? const Duration(seconds: 3));
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    required int position,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(roundedTop ? 8 : 0),
              bottom: Radius.circular(roundedBottom ? 8 : 0),
            ),
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            )),
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              child: caption ?? const SizedBox(),
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Story embed widget

  factory StoryItem.embed(
    String data, {
    Key? key,
    bool shown = false,
    required int position,
    required StoryController controller,
    double? aspectRatio,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        child: SizedBox(
          child: StoryEmbed(
            embedData: data,
            aspectRatio: aspectRatio,
            controller: controller,
          ),
          width: double.infinity,
        ),
      ),
      shown: shown,
      position: position,
      duration: duration ?? const Duration(minutes: 1),
    );
  }
}

/// Widget to display stories just like Whatsapp and Instagram. Can also be used
/// inline/inside [ListView] or [Column] just like Google News app. Comes with
/// gestures to pause, forward and go to previous page.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<StoryItem?> storyItems;

  final BaseStory storyGroup;

  //final List<BaseStoryItem> element;

  /// Callback for when a full cycle of story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferrable to not to
  /// provide this callback so as to enable scroll events on the list view.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story is currently being shown.
  final ValueChanged<StoryItem>? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  /// If you would like to display the story as full-page, then set this to
  /// `false`. But in case you would display this as part of a page (eg. in
  /// a [ListView] or [Column]) then set this to `true`.
  final bool inline;

  // Controls the playback of the stories
  final StoryController controller;

  final Function(StoryController, dynamic)? linkPressed;

  final Function(StoryController, dynamic)? categoryIconPressed;

  final StoryConfig? storyConfig;

  final ValueNotifier<bool> isAutoScroll;

  const StoryView({
    Key? key,
    required this.storyItems,
    required this.controller,
    this.linkPressed,
    this.categoryIconPressed,
    this.onComplete,
    this.onStoryShow,
    this.storyConfig,
    required this.storyGroup,
    required this.isAutoScroll,
    this.progressPosition = ProgressPosition.top,
    this.repeat = false,
    this.inline = false,
    this.onVerticalSwipeComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  VerticalDragInfo? verticalDragInfo;

  double uiElementOpacity = 1.0;
  ValueNotifier<bool> bottomUiElementHide = ValueNotifier(false);

  StoryItem? get _currentStory {
    return widget.storyItems.firstWhereOrNull((it) => !it!.shown);
  }

  Widget get _currentView {
    var item = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    item ??= widget.storyItems.last;
    return Container(
        foregroundDecoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: <Color>[
            Colors.black45,
            Colors.transparent,
            Colors.transparent,
          ],
        )),
        child: item?.view);
  }

  @override
  void initState() {
    super.initState();

    // All pages after the first unshown page should have their shown value as
    // false
    final firstPage = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    if (firstPage == null) {
      for (var it2 in widget.storyItems) {
        it2!.shown = false;
      }
    } else {
      final lastShownPos = widget.storyItems.indexOf(firstPage);
      widget.storyItems.sublist(lastShownPos).forEach((it) {
        it!.shown = false;
      });
    }

    _playbackSubscription = widget.controller.playbackNotifier.listen((playbackStatus) {
      //print('StoryViewState.initState ${playbackStatus}');
      switch (playbackStatus) {
        case PlaybackState.play:
          _removeNextHold();
          bottomUiElementHide.value = false;
          _animationController?.forward();
          break;

        case PlaybackState.pause:
          _holdNext(); // then pause animation
          bottomUiElementHide.value = true;
          _animationController?.stop(canceled: false);
          break;

        case PlaybackState.next:
          _removeNextHold();
          _goForward();
          break;

        case PlaybackState.previous:
          _removeNextHold();
          _goBack();
          break;
      }
    });

    _play();
  }

  @override
  void dispose() {
    _clearDebouncer();

    _animationController?.dispose();
    _playbackSubscription?.cancel();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _animationController?.dispose();
    // get the next playing page
   // print('StoryViewState._play ${widget.storyItems}');
    final storyItem = widget.storyItems.firstWhere((it) {
     // print('StoryViewState._play601');
      widget.controller.play();
      return !it!.shown;
    })!;

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem);
    }

    _animationController = AnimationController(duration: storyItem.duration, vsync: this);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.shown = true;
        if (widget.storyItems.last != storyItem) {
          //print('StoryViewState._play');
          _beginPlay();
        } else {
          // done playing
         // print('StoryViewState._onComplete');
          _onComplete();
        }
      }
    });

    _currentAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    //widget.controller.pause();
  }

  void _beginPlay() {
    setState(() {});
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
      widget.isAutoScroll.value = true;
    }

    if (widget.repeat) {
      for (var it in widget.storyItems) {
        it!.shown = false;
      }

      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (_currentStory == null) {
      widget.storyItems.last!.shown = false;
    }

    if (_currentStory == widget.storyItems.first) {
      _beginPlay();
    } else {
      _currentStory!.shown = false;
      int lastPos = widget.storyItems.indexOf(_currentStory);
      final previous = widget.storyItems[lastPos - 1]!;

      previous.shown = false;

      _beginPlay();
    }
  }

  void _goForward() {
    if (_currentStory != widget.storyItems.last) {
      _animationController!.stop();

      // get last showing
      final _last = _currentStory;

      if (_last != null) {
        _last.shown = true;
        if (_last != widget.storyItems.last) {
          _beginPlay();
        }
      }
    } else {
      // this is the last page, progress animation should skip to end
      _animationController!.animateTo(1.0, duration: const Duration(milliseconds: 10));
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(const Duration(milliseconds: 500), () {});
  }

  double get topSpaceValue => MediaQuery.of(context).padding.top + 8;

  void uiElementChangeOpacity() {
    uiElementOpacity = uiElementOpacity == 1.0 ? 0.0 : 1.0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    BaseStoryItem baseStoryItem = widget.storyGroup.storyItems[_currentStory?.position ?? 0];
    BaseStory baseStory = widget.storyGroup;
    //print('_StoryPageViewState.initState ${widget.storyConfig}');
    final String languageCode = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          _currentView,
          Positioned.fill(
              child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: uiElementOpacity,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black26.withOpacity(0.75), Colors.black12, Colors.transparent],
                        ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: baseStoryItem.description != null
                            ? LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [Colors.black26.withOpacity(0.75), Colors.black12, Colors.transparent],
                              )
                            : null,
                      ),
                    )),
              ],
            ),
          )),
          Positioned.fill(
              child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    widget.controller.previous();
                  },
                  onLongPress: () {
                    widget.controller.pause();
                    uiElementChangeOpacity();
                  },
                  onLongPressUp: () {
                    widget.controller.play();
                    uiElementChangeOpacity();
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    widget.controller.next();
                  },
                  onLongPress: () {
                    widget.controller.pause();
                    uiElementChangeOpacity();
                  },
                  onLongPressUp: () {
                    widget.controller.play();
                    uiElementChangeOpacity();
                  },
                ),
              ),
            ],
          )),
          Align(
            alignment: widget.progressPosition == ProgressPosition.top ? Alignment.topCenter : Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: uiElementOpacity,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    PageBar(
                      widget.storyItems.map((it) => PageData(it!.duration, it.shown)).toList(),
                      _currentAnimation,
                      key: UniqueKey(),
                      indicatorHeight: widget.inline ? IndicatorHeight.small : IndicatorHeight.large,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            // print('StoryViewState.build');
                            widget.categoryIconPressed?.call(widget.controller, widget.storyGroup);
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: CachedNetworkImageProvider(baseStory.mainCategoryImagePath),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (baseStory.title != null && (baseStory.title?.isNotEmpty ?? false))
                                Text(baseStory.title!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.storyConfig?.titleStyle ??
                                        const TextStyle(
                                          fontSize: 12,
                                          height: 1.33,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        )),
                              Text(
                                timeago.format(baseStoryItem.createdDate ?? DateTime.now(), locale: languageCode),
                                style: widget.storyConfig?.dateStyle ??
                                    TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.75),
                                        fontWeight: FontWeight.w600,
                                        height: 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                icon: const Icon(Icons.clear),
                                color: Colors.white.withOpacity(0.78),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: uiElementOpacity,
              child: ValueListenableBuilder(
                valueListenable: bottomUiElementHide,
                builder: (BuildContext context, bool value, Widget? child) {
                  return value
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (baseStoryItem.description != null)
                              TextButton(
                                  onPressed: () async {
                                    widget.controller.pause();
                                    await showModalBottomSheet<void>(
                                      context: context,
                                      elevation: 0,
                                      barrierColor: Colors.black.withAlpha(1),
                                        isScrollControlled:true,
                                      backgroundColor: Colors.black26.withOpacity(0.5),
                                      builder: (BuildContext context) {
                                        return Container(
                                          constraints:
                                              BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                                          child: Scrollbar(
                                           // controller: scrollController,
                                            thumbVisibility: true,
                                            child: SingleChildScrollView(
                                           //   controller: scrollController,
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                baseStoryItem.description!,
                                                style: widget.storyConfig?.contentStyle ??
                                                    const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    widget.controller.play();
                                  },
                                  child: Text(
                                    baseStoryItem.description!,
                                    maxLines: 2,
                                    overflow:TextOverflow.ellipsis,
                                    style: widget.storyConfig?.contentStyle ??
                                        const TextStyle(color: Colors.white),
                                  )),
                            if (baseStoryItem.url != null)
                              ElevatedButton(
                                  onPressed: () {
                                    widget.linkPressed?.call(
                                        widget.controller, widget.storyGroup.storyItems[_currentStory?.position ?? 0]);
                                  },
                                  style: widget.storyConfig?.moreButtonStyle ??
                                      ElevatedButton.styleFrom(
                                        primary: const Color(0x1111118c),
                                        shape: const StadiumBorder(),
                                      ),
                                  child: Text(
                                    detailButtonTitle[languageCode] ?? detailButtonTitle['en']!,
                                    style:
                                        const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                  )),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, String> detailButtonTitle = {'en': 'SHOW DETAIL','fr': 'MONTRER LES DÉTAILS', 'ar': 'انظر التفاصيل', 'tr': 'DETAYI GÖR','ru':'ПОКАЗАТЬ ДЕТАЛИ'};

  Widget topSpace() {
    return SizedBox(
      height: topSpaceValue,
    );
  }
}

/// Capsule holding the duration and shown property of each story. Passed down
/// to the pages bar to render the page indicators.
class PageData {
  Duration duration;
  bool shown;

  PageData(this.duration, this.shown);
}

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final IndicatorHeight indicatorHeight;

  const PageBar(
    this.pages,
    this.animation, {
    this.indicatorHeight = IndicatorHeight.large,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 1 : ((count > 10) ? 2 : 4);

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.pages.map((it) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.only(right: widget.pages.last == it ? 0 : spacing),
            child: StoryProgressIndicator(
              isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
              indicatorHeight: widget.indicatorHeight == IndicatorHeight.large ? 5 : 3,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Custom progress bar. Supposed to be lighter than the
/// original [ProgressIndicator], and rounded at the sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;

  const StoryProgressIndicator(
    this.value, {
    Key? key,
    this.indicatorHeight = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int angleValue;
    Locale myLocale = Localizations.localeOf(context);
    if (myLocale.languageCode == 'ar'){
      angleValue = 90;
      } else {
        angleValue = 1;
      }
    return Transform.rotate(
      angle: 90 * pi/angleValue, ///arapçada 90 diğer türlü 1 olacak
      child: CustomPaint(
        size: Size.fromHeight(
          indicatorHeight,
        ),
        foregroundPainter: IndicatorOval(
          Colors.white.withOpacity(0.8),
          value,
        ),
        painter: IndicatorOval(
          Colors.white.withOpacity(0.4),
          1.0,
        ),
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorOval(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * widthFactor, size.height), const Radius.circular(3)),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(int? r, int? g, int? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) / luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}
