
import 'package:flutter/material.dart';
import '../controller/story_controller.dart';

class StoryEmbed extends StatefulWidget {
  const StoryEmbed({Key? key, this.controller, this.loadingWidget, this.aspectRatio, required this.embedData})
      : super(key: key);
  final StoryController? controller;

  final Widget? loadingWidget;
  final double? aspectRatio;
  final String embedData;

  @override
  State<StoryEmbed> createState() => _StoryEmbedState();
}

class _StoryEmbedState extends State<StoryEmbed> {

  @override
  void initState() {
    widget.controller?.pause();
    super.initState();
  }

  Widget getContentView() {
    return const Center(
     child: Text('Not Supported Embed' , style: TextStyle(color: Colors.white60),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

}
