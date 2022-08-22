import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tangram/tools/key_provider.dart';
import 'dart:math';
import 'package:webviewx/webviewx.dart';
import 'package:flutter_tangram/widgets/webview_helpers.dart';

class HDWebView extends StatefulWidget {
  const HDWebView({Key? key}) : super(key: key);

  @override
  State<HDWebView> createState() => _HDWebViewState();
}

class _HDWebViewState extends State<HDWebView> {
  late WebViewXController webviewController;
  final initialContent =
      '<h1 style="position:absolute;left:50%;top:50%;display:block;transform:translate(-50%,-50%);"> 欢迎使用七巧板应用 <h1>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iframe embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iframe, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;
  bool _showMenus = false;
  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const KEYCODE_DPAD_CENTER = 23;
    const KEYCODE_ENTER = 66;
    return Scaffold(
        appBar: null,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            listenKeyboardDown([KEYCODE_ENTER, KEYCODE_DPAD_CENTER], (() {
              setState(() {
                _showMenus = !_showMenus;
              });
            })),
            _buildWebViewX(),
            _buildButtons(),
          ],
        ));
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: initialContent,
      initialSourceType: SourceType.html,
      height: screenSize.height,
      width: screenSize.width,
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) =>
          debugPrint('A new page has started loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('The page has finished loading: $src\n'),
      jsContent: const {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
    );
  }

  void _setUrl() {
    webviewController.loadContent(
      'https://haidaotech.atlassian.net/',
      SourceType.url,
    );
  }

  Future<void> _goForward() async {
    if (await webviewController.canGoForward()) {
      await webviewController.goForward();
      showSnackBar('Did go forward', context);
    } else {
      showSnackBar('Cannot go forward', context);
    }
  }

  Future<void> _goBack() async {
    if (await webviewController.canGoBack()) {
      await webviewController.goBack();
      showSnackBar('Did go back', context);
    } else {
      showSnackBar('Cannot go back', context);
    }
  }

  void _reload() {
    webviewController.reload();
  }

  Widget _buildButtons() {
    final List<InkWell> menusButtons = [
      createButton(
          onTap: _goBack,
          text: 'Back',
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white)),
      createButton(
          onTap: _goForward,
          text: 'Forward',
          icon: const Icon(Icons.arrow_forward_outlined, color: Colors.white)),
      createButton(
          onTap: _reload,
          text: 'Reload',
          icon: const Icon(Icons.replay_rounded, color: Colors.white)),
      createButton(
          text: 'https://haidaotech.atlassian.net/',
          onTap: _setUrl,
          icon: const Icon(Icons.search_rounded, color: Colors.white)),
    ];

    /// 对左键进行处理
    keyCodeDpadLeft(BuildContext context, InkWell param) async {
      /// 首位边界处理
      final int _idx = menusButtons.indexWhere((e) => e == param);
      if (_idx == 0) return;
      final int _nextIndex = _idx + 1;
      if ((_nextIndex % 4) == 1) {
        InkWell _nextNode = menusButtons[_idx - 1];
        await Future.delayed(const Duration(milliseconds: 20));
        _nextNode.focusNode?.requestFocus();
      }
    }

    /// 对右键进行处理
    keyCodeDpadRight(BuildContext context, InkWell param) async {
      final int _idx = menusButtons.indexWhere((e) => e == param);

      /// 末位边界处理
      if (_idx == (menusButtons.length - 1)) return;

      final int _nextIndex = _idx + 1;
      if ((_nextIndex % 4) == 0) {
        InkWell _nextNode = menusButtons[_nextIndex];
        await Future.delayed(const Duration(milliseconds: 20));
        _nextNode.focusNode?.requestFocus();
      }
    }

    focusEventHandler(
        RawKeyEvent event, BuildContext context, InkWell param) async {
      /// 只处理按键按下的事件
      if (event.data is RawKeyEventDataAndroid &&
          event.runtimeType.toString() == 'RawKeyDownEvent') {
        CustomRawKeyEventDataAndroid _d =
            CustomRawKeyEventDataAndroid.format(event.data);

        /// 对左键进行处理
        if (_d.keyCode == 21) {
          await keyCodeDpadLeft(context, param);
        }

        /// 对右键进行处理
        if (_d.keyCode == 22) {
          await keyCodeDpadRight(context, param);
        }
      }
    }

    bool init = false;
    if (!init) {
      menusButtons.first.focusNode?.requestFocus();
      init = true;
    }

    return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent event) =>
            focusEventHandler(event, context, menusButtons.first),
        child: AnimatedOpacity(
            opacity: _showMenus ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: _showMenus
                ? Container(
                    width: screenSize.width,
                    height: screenSize.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(120, 68, 137, 255),
                          Color.fromARGB(100, 68, 137, 255)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: screenSize.width / 2,
                        height: screenSize.height / 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: menusButtons,
                        ),
                      ),
                    ))
                : Container()));
  }
}
