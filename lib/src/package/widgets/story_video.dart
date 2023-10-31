import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../controller/story_controller.dart';
import '../utils.dart';

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (videoFile != null) {
      state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager().getFileStream(url, headers: requestHeaders as Map<String, String>?);

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (videoFile == null) {
          state = LoadState.success;
          videoFile = fileResponse.file;
          onComplete();
        }
      }
    });
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;
  final Widget? loadingWidget;

  StoryVideo(this.videoLoader, {this.storyController, this.loadingWidget, Key? key}) : super(key: key ?? UniqueKey());

  static StoryVideo url(String url,
      {StoryController? controller, Widget? loadingWidget, Map<String, dynamic>? requestHeaders, Key? key}) {
    return StoryVideo(VideoLoader(url, requestHeaders: requestHeaders),
        storyController: controller, key: key, loadingWidget: loadingWidget);
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  late BetterPlayerController _betterPlayerController;

  late StreamSubscription<PlaybackState>? playbackNotifierSubscription;
  PlaybackState? playbackState;

  @override
  void initState() {
    super.initState();

    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
        //autoPlay: true,
        fit: BoxFit.contain,

        aspectRatio: 9 / 16,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        controlsConfiguration:
            BetterPlayerControlsConfiguration(
                showControls: true,

                loadingWidget: widget.loadingWidget, loadingColor: Colors.red));

    BetterPlayerDataSource dataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.videoLoader.url);

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setControlsAlwaysVisible(false);
    _betterPlayerController.setControlsEnabled(false);


    _betterPlayerController.addEventsListener(betterPlayerListener);

    // playerController.addListener(videoListen);

    playbackNotifierSubscription = widget.storyController?.playbackNotifier.listen(storyControllerListen);

    // playerController.initialize().then(videoInit);
    widget.storyController!.pause();
    //playerController.play();
  }

  void betterPlayerListener(BetterPlayerEvent event) {
    //print('StoryVideoState.betterPlayerListener ${event.betterPlayerEventType} ');
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      videoInit();
    }
  }

  void storyControllerListen(PlaybackState playbackState) {
    debugPrint('StoryVideoState.storyControllerListen $playbackState');
    this.playbackState = playbackState;
    if (playbackState == PlaybackState.pause) {
      _betterPlayerController.pause();
    } else if (playbackState == PlaybackState.play && (_betterPlayerController.isVideoInitialized() ?? false)) {
      _betterPlayerController.play();
    } else if (playbackState == PlaybackState.previous) {
      if(_betterPlayerController.isPlaying() ?? false){
        _betterPlayerController.videoPlayerController?.seekTo(const Duration(seconds: 0));
      }
    }else {
     // widget.storyController!.pause();
    }
  }

  void videoListen() {
    bool isPlaying = _betterPlayerController.isPlaying() ?? false;

    debugPrint('StoryVideoState.videoListen isPlaying $isPlaying');
    debugPrint('StoryVideoState.videoListen $playbackState');
    //print('StoryVideoState.videoListen ${playerController.value.}');
    /* if (playbackState == PlaybackState.play) {
       playerController.play();
       isPlaying = true;
    } else {
      playerController.pause();
      isPlaying = false;
    }*/

    if (isPlaying) {
      if (playbackState != PlaybackState.play) {
        widget.storyController?.play();
      }
      //widget.storyController?.play();
    } else {
      if (playbackState != PlaybackState.pause) {
        widget.storyController?.pause();
      }

      /* if (playerController.value.position.inSeconds >= playerController.value.duration.inSeconds) {
        widget.storyController?.next();
      }*/
    }
  }

  void videoInit() {
    debugPrint("Video Controller videoInit");
    // setState(() {});
    widget.storyController?.play();
  }

  Widget getContentView() {
    return BetterPlayer(
      controller: _betterPlayerController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    //playerController.dispose();
    playbackNotifierSubscription?.cancel();
    super.dispose();
  }
}
