// screens/planner_5d_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; //  ✅ استيراد المكتبة
// #docregion platform_imports
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class Planner5DViewerScreen extends StatefulWidget {
  final String plannerUrl; //  الـ URL الكامل للمخطط

  const Planner5DViewerScreen({super.key, required this.plannerUrl});

  @override
  State<Planner5DViewerScreen> createState() => _Planner5DViewerScreenState();
}

class _Planner5DViewerScreenState extends State<Planner5DViewerScreen> {
  late final WebViewController _controller;
  bool _isLoadingPage = true;

  @override
  void initState() {
    super.initState();

    // #docregion platform_ spécifiques
    // late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    // final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_specifics
    //  الكود أعلاه للإعدادات المتقدمة، يمكن البدء بالأساسي:

    _controller =
        WebViewController()
          ..setJavaScriptMode(
            JavaScriptMode.unrestricted,
          ) //  السماح بـ JavaScript (مهم لمعظم العارضين)
          ..setBackgroundColor(
            const Color(0x00000000),
          ) //  خلفية شفافة للـ WebView نفسه (اختياري)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                //  تحديث مؤشر التحميل (اختياري)
                debugPrint('WebView is loading (progress : $progress%)');
              },
              onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
                if (mounted) {
                  setState(() => _isLoadingPage = true);
                }
              },
              onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');
                if (mounted) {
                  setState(() => _isLoadingPage = false);
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
                if (mounted) {
                  setState(() => _isLoadingPage = false);
                  //  يمكنكِ عرض رسالة خطأ هنا
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                //  يمكنكِ هنا التحكم في أي روابط يتم فتحها داخل الـ WebView
                //  وأي روابط يتم فتحها في متصفح خارجي
                // if (request.url.startsWith('https://www.youtube.com/')) {
                //   debugPrint('blocking navigation to ${request.url}');
                //   return NavigationDecision.prevent;
                // }
                debugPrint('allowing navigation to ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.plannerUrl)); //  ✅ تحميل الـ URL

    // #docregion platform_features
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }
    // #enddocregion platform_features

    // _controller = controller; //  تم تعيينه مباشرة أعلاه
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Project View'),
        actions: [
          //  أزرار تحكم اختيارية للـ WebView
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              } else {
                // ignore: use_build_context_synchronously
                if (Navigator.canPop(context)) Navigator.pop(context);
                return;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              } else {
                return;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoadingPage) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
