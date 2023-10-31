import 'package:example/story_model.dart';
import 'package:example/story_service.dart';
import 'package:example/webview_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pirimedya_story/pirimedya_story.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

SystemUiOverlayStyle style =SystemUiOverlayStyle(
  // systemNavigationBarColor: Colors.blue, // navigation bar color asdsd
  statusBarColor: Colors.green, // status bar color
);
void main() async {

  SystemChrome.setSystemUIOverlayStyle(style);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Story>?> _value;
  late StoryMockService service;
  late SharedPreferences prefs;
  late EventBus eventBus;

  @override
  void initState() {
    service = StoryMockService();
    eventBus = EventBus();
    _value = fetchStory();
    super.initState();
  }

  Future<List<Story>?> fetchStory() async {
    await Future.delayed(const Duration(seconds: 1));
    prefs = await SharedPreferences.getInstance();
    return service.getStory();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
     // theme: ThemeData.light().copyWith(appBarTheme: ThemeData.light().appBarTheme.copyWith(systemOverlayStyle: style)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('Material App Bar'),
        ),
        body: Column(
          children: [
            FutureBuilder<List<Story>?>(
                future: _value,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                      height: 250,
                      child: StoryListView(
                        count: snapshot.data?.length ?? 0,
                        storyData: snapshot.data,
                        eventBus: eventBus,
                        linkPressed: (controller, value) async {
                          if (value is StoryElement) {
                            controller.pause();
                            await open(value,context);
                            controller.play();
                          }
                        },
                        categoryIconPressed: (controller, value) async {
                          controller.pause();
                          await open(value,context);
                          controller.play();
                        },
                        storyConfig: StoryConfig(
                            moreButtonStyle: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const StadiumBorder(),
                            )
                        ),
                        sharedPreferences: prefs,
                        groupPressed:(value)async{
                          Future.delayed(const Duration(seconds: 3));
                          return true;
                        },
                        loadingWidget: Container(
                          width: 80,
                          height: 80,
                          color: Colors.white,
                        ),
                        refreshKey: 'HomeStory',
                      ));
                }),
            const Center(
              child: Text('Selam Ben Story Test   '),
            ),
          ],
        ),
      ),
    );
  }



  open(StoryElement value ,context) async {
    print('Url open ${value.url}');
      await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.3),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation1, animation2) => const WebviewTestScreen(),
      ),
    );
    print('Url close ${value.url}');
  }
}
