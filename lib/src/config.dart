import 'package:flutter/material.dart';

class StoryConfig{

  final ButtonStyle? moreButtonStyle;
  final Decoration? topBehindDecoration;
  final Decoration? bottomBehindDecoration;
  final TextStyle? titleStyle;
  final TextStyle? dateStyle;
  final TextStyle? contentStyle;

  const StoryConfig( {this.moreButtonStyle,this.topBehindDecoration, this.bottomBehindDecoration, this.titleStyle, this.dateStyle,this.contentStyle, });
}