

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
class WebviewTestScreen extends StatefulWidget {
  const WebviewTestScreen({Key? key}) : super(key: key);

  @override
  State<WebviewTestScreen> createState() => _WebviewTestScreenState();
}

class _WebviewTestScreenState extends State<WebviewTestScreen> {

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      body: Text('')
    );
  }
}
