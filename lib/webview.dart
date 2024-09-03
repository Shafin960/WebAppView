import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key});

  @override
  State<WebViewContainer> createState() {
    return _WebViewContainerState();
  }
}

class _WebViewContainerState extends State<WebViewContainer> {
  WebViewController controller = WebViewController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      egrerg();
    });
  }

  Future<void> egrerg() async {
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.addJavaScriptChannel(
      'loadingDone',
      onMessageReceived: (JavaScriptMessage message) {
        print("Showing ${message.message}");
        setState(() {
          loading = true;
        });
      },
    );
    await controller.addJavaScriptChannel(
      'leavingDone',
      onMessageReceived: (JavaScriptMessage message) {
        print("Showing ${message.message}");
        setState(() {
          loading = false;
        });
      },
    );
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) => print("page started"),
        onPageFinished: (String url) => print("page loaded"),
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) =>
            NavigationDecision.navigate,
      ),
    );
    await controller.loadRequest(Uri.parse(
        //'https://bss-restaurant-k9ridstrk-mushfiques-projects.vercel.app/tables'
        'https://omniawonen-test.siderian.cloud/'));
  }

  Future<void> jS() async {
    // await controller.runJavaScript('''
    //     var containerDiv = document.querySelector('.admin');
    //     var paragraph = document.createElement('p');
    //     paragraph.textContent = 'This paragraph was added from flutter.';
    //     containerDiv.appendChild(paragraph);
    //     ''');
    await controller.runJavaScript('addParagraph();');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(controller: controller),
        floatingActionButton: loading
            ? FloatingActionButton(
                onPressed: () {
                  jS();
                },
              )
            : null,
      ),
    );
  }
}
