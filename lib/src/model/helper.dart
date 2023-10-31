import 'dart:core';

import 'package:pirimedya_story/src/model/base_story.dart';

class HelperStory implements Comparable<HelperStory> {
  final BaseStory baseStory;
  final int? timestamps;

  HelperStory(this.baseStory, {this.timestamps});

  HelperStory copyWith({BaseStory? baseStory, int? timestamps}) {
    return HelperStory(baseStory ?? this.baseStory, timestamps: timestamps ?? this.timestamps);
  }

  bool get isSeen => (timestamps ?? 0) != 0;

  @override
  int compareTo(HelperStory other) {
    final int valueA = other.timestamps ?? 0;
    final int valueB = timestamps ?? 0;

    if (valueB == 0) {
      return 0;
    }
    if (valueA == 0) {
      if (valueB > valueA) {
        return 1;
      }
    }
    if (valueB > valueA) {
      return 0;
    } else if (valueB < valueA) {
      return 1;
    } else {
      return 0;
    }
  }
}
