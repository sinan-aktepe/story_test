
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pirimedya_story.dart';

class PiriStoryController {
  final SharedPreferences sharedPreferences;

  PiriStoryController(this.sharedPreferences);

  void init(List<BaseStory> storyList) {
    sortStoryForTimestamp(storyList);
  }

  bool isStoryGroupSeen(String storyId) {

  /* int currentPosition = checkLocalStoryElementPosition(storyId);
    if(groupLength > currentPosition){
      clearLocalTimestampData(storyId);
    }*/

    return (sharedPreferences.getInt(storyId) ?? 0) != 0;
  }



  int checkLocalStoryElementPosition(String storyId) {
    return sharedPreferences.getInt(elementPositionKey(storyId)) ?? 0;
  }

  setSeenStoryTimestamp(String storyId) {
    int localTime = (sharedPreferences.getInt(storyId) ?? 0);

    if (localTime == 0) {
      sharedPreferences.setInt(storyId, DateTime.now().millisecondsSinceEpoch);
    }
  }

  void setSeenStoryElement(String storyId, int position) {
    sharedPreferences.setInt(elementPositionKey(storyId), position);
  }

  void sortStoryForTimestamp(List<BaseStory> storyList) {
    insertionSort<BaseStory>(storyList, compare: storyCompare);
  }

  ///Şuan düzgün bir yöntem bulunamadı,
  clearLocalTimestampData(String storyId,) {
    //sharedPreferences.remove(storyId);
  }

  int storyCompare(BaseStory a, BaseStory b) {
    final int valueA = sharedPreferences.getInt(a.storyId) ?? 0;
    final int valueB = sharedPreferences.getInt(b.storyId) ?? 0;


    if (valueB == 0) {
      return 0;
    }
    if (valueA == 0) {
      if (valueB > valueA) {
        return -1;
      }
    }
    if (valueB > valueA) {
      return 0;
    } else if (valueB < valueA) {
      return -1;
    } else {
      return 0;
    }
  }

  String elementPositionKey(String storyId) => '$storyId element-position';

  dispose() {}
}
