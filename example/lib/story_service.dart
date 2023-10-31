


import 'package:example/mock_data.dart';
import 'package:example/story_model.dart';

class StoryMockService{

  List<Story>? getStory() {
    try{
      List<Story> data = storyFromJson(MockData.storyData);

     // data.forEach((element) { print(element.stories);});
      return data ;
    }catch (e){
      print('StoryMockService.getStory.error $e');
      return null;
    }

  }

}