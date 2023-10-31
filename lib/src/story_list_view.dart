import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../pirimedya_story.dart';
import 'controller/piri_story_contoller.dart';
import 'package/story_view.dart';
import 'story_page_view.dart';
import 'widgets/story_list_item.dart';

typedef StoryItemBuilder = Widget Function(BuildContext context, int index, bool isSeen);

// version 0.1.1
class StoryListView extends StatefulWidget {
  const StoryListView(
      {Key? key,
      required this.count,
      this.storyData,
      this.storyAspectRatio,
      required this.sharedPreferences,
      this.refreshKey,
      this.storyConfig,
      this.storyItemBuilder,
      this.loadingWidget,
      this.linkPressed,
      this.groupPressed,
      this.categoryIconPressed,
      this.scrollController,
      required this.eventBus})
      : super(key: key);
  final int count;
  final double? storyAspectRatio;
  final List<BaseStory>? storyData;
  final String? refreshKey;
  final EventBus eventBus;
  final StoryItemBuilder? storyItemBuilder;
  final SharedPreferences sharedPreferences;
  final Function(StoryController, dynamic)? linkPressed;
  final Future<bool> Function(dynamic)? groupPressed;
  final Function(StoryController, dynamic)? categoryIconPressed;
  final Widget? loadingWidget;
  final StoryConfig? storyConfig;
  final ScrollController? scrollController;
  @override
  State<StoryListView> createState() => _StoryListViewState();

  static _StoryListViewState? of(BuildContext context) => context.findAncestorStateOfType<_StoryListViewState>();
}

class _StoryListViewState extends State<StoryListView> {
  late PiriStoryController piriStoryController;
  late StreamSubscription refreshSubscription;

  @override
  void initState() {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    piriStoryController = PiriStoryController(
      widget.sharedPreferences,
    );
    refreshSubscription = widget.eventBus.on<PiriStoryRefreshEvent>().listen(listenRefreshEvent);
    initData();
    super.initState();
  }

  initData() {
    sortStoryAndUpdateWidget();
  }

  void listenRefreshEvent(PiriStoryRefreshEvent event) {
    if (widget.refreshKey == null || widget.refreshKey == event.key) {
      sortStoryAndUpdateWidget();
    }
  }

  void updateWidget() {
    if (mounted) {
      setState(() {});
    }
  }

  void sortStoryAndUpdateWidget() {
    piriStoryController.sortStoryForTimestamp(widget.storyData ?? []);
    updateWidget();
  }

  void saveDataToStore() {}

  void setupStore() async {}

  @override
  void dispose() {
    refreshSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final String languageCode = Localizations.localeOf(context).languageCode;

    //timeago.setLocaleMessages('tr', timeago.TrMessages());

    return ListView.builder(
        controller: widget.scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.storyData?.length ?? 0,
        itemBuilder: (context, index) {
          return widget.storyItemBuilder != null
              ? wrapper(
                  widget.storyItemBuilder!(
                      context, index, piriStoryController.isStoryGroupSeen(widget.storyData![index].storyId)),
                  index,
                )
              : wrapper(
                  StoryListItem(
                    key: ValueKey<String>(widget.storyData![index].storyId),
                    aspectRatio: widget.storyAspectRatio ?? 10 / 17,
                    baseStory: widget.storyData![index],
                    index: index,
                    isSeen: piriStoryController.isStoryGroupSeen(widget.storyData![index].storyId),
                  ),
                  index);
        });
  }

  Widget wrapper(Widget child, int index) => GestureDetector(
        child: child,
        onTap: () async {
          final result = await widget.groupPressed?.call(widget.storyData?[index]) ?? true;
          if (!result) return;
          await Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.3),
              reverseTransitionDuration: const Duration(milliseconds: 50),
              transitionDuration: const Duration(milliseconds: 250),
              pageBuilder: (context, animation1, animation2) => StoryPageView(
                initialIndex: index,
                storyConfig: widget.storyConfig,
                linkPressed: widget.linkPressed,
                loadingWidget: widget.loadingWidget,
                categoryIconPressed: widget.categoryIconPressed,
                piriStoryController: piriStoryController,
                storyData: widget.storyData ?? [],
              ),
            ),
          );
          sortStoryAndUpdateWidget();
        },
      );
}
