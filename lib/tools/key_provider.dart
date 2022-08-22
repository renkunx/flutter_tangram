import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePageContentWidgetProvider with ChangeNotifier {
  bool init = false;
  double maxWScreen = 0; // 按钮距离屏幕右侧最大边界
  double minWScreen = 60; // 按钮距离屏幕最左侧距离边界

  final List<HomePageMakeBtn> makeBtnList = [
    HomePageMakeBtn('lib/assets/img/youtube.png', 'You Tube', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/apple.png', 'Apple', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/facebook.png', 'Facebook', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/douyin.png', 'Tik Tok', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/mi.png', 'MI', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/huawei.png', 'Hua Wei', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/youtube.png', 'TTT', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/apple.png', 'DDDD', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/facebook.png', 'FFFF', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/douyin.png', 'AAAA', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/mi.png', 'QQQQQ', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/huawei.png', 'WWWW', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/youtube.png', 'EEEEE', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/apple.png', 'RRRRR', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/facebook.png', 'YYYYYY', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/douyin.png', 'UUUUUU', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/mi.png', 'SSSSS', '', FocusNode()),
    HomePageMakeBtn('lib/assets/img/huawei.png', 'VVVV', '', FocusNode()),
  ];

  HomePageContentWidgetProvider(BuildContext context) {
    maxWScreen = MediaQuery.of(context).size.width - 246;
    if (!init) {
      makeBtnList.first.focusNode.requestFocus();
      init = true;
    }
  }

  setMakeFocusAddListener() {
    for (int i = 0; i < makeBtnList.length; i++) {
      makeBtnList[i].focusNode.addListener(() {
        if (makeBtnList[i].focusNode.hasFocus) {
          // notifyListeners();
          print(
              '====${makeBtnList[i].name} : ${makeBtnList[i].focusNode.hasFocus}');
        }
      });
    }
  }

  setMakeFocusDispose() {
    for (var item in makeBtnList) {
      item.focusNode.removeListener(() {});
      item.focusNode.dispose();
    }
  }

  /// 对左键进行处理
  keyCodeDpadLeft(BuildContext context, HomePageMakeBtn param) async {
    /// 首位边界处理
    final int _idx = makeBtnList.indexWhere((e) => e == param);
    if (_idx == 0) return;
    final int _nextIndex = _idx + 1;
    if ((_nextIndex % 7) == 1) {
      HomePageMakeBtn _nextNode = makeBtnList[_idx - 1];
      print(_nextNode.name);
      await Future.delayed(const Duration(milliseconds: 20));
      _nextNode.focusNode.requestFocus();
    }
  }

  /// 对右键进行处理
  keyCodeDpadRight(BuildContext context, HomePageMakeBtn param) async {
    final int _idx = makeBtnList.indexWhere((e) => e == param);

    /// 末位边界处理
    if (_idx == (makeBtnList.length - 1)) return;

    final int _nextIndex = _idx + 1;
    if ((_nextIndex % 7) == 0) {
      HomePageMakeBtn _nextNode = makeBtnList[_nextIndex];
      await Future.delayed(const Duration(milliseconds: 20));
      _nextNode.focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    setMakeFocusDispose();
    super.dispose();
  }
}

class HomePageMakeBtn {
  final String img;
  final String name;
  final String routerName;
  final FocusNode focusNode;

  HomePageMakeBtn(this.img, this.name, this.routerName, this.focusNode);
}

class CustomRawKeyEventDataAndroid {
  final int flags;
  final int codePoint;
  final int plainCodePoint;

  /// case 19: KEY_UP
  /// case 20: KEY_DOWN
  /// case 21: KEY_LEFT
  /// case 22: KEY_RIGHT
  /// case 23: KEY_CENTER
  final int keyCode;
  final int scanCode;
  final int metaState;

  CustomRawKeyEventDataAndroid(this.flags, this.codePoint, this.plainCodePoint,
      this.keyCode, this.scanCode, this.metaState);

  static CustomRawKeyEventDataAndroid format(d) {
    return CustomRawKeyEventDataAndroid(d.flags, d.codePoint, d.plainCodePoint,
        d.keyCode, d.scanCode, d.metaState);
  }
}
