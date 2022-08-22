import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviewx/webviewx.dart';

import '../tools/key_provider.dart';

/// This dialog will basically show up right on top of the webview.
///
/// AlertDialog is a widget, so it needs to be wrapped in `WebViewAware`, in order
/// to be able to interact (on web) with it.
///
/// Read the `Readme.md` for more info.
void showAlertDialog(String content, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => WebViewAware(
      child: AlertDialog(
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 1),
      ),
    );
}

InkWell createButton(
    {VoidCallback? onTap, required String text, required Icon icon}) {
  return InkWell(
      splashColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
              ),
              child: icon,
              focusNode: FocusNode()),
          // Text(text)
        ],
      ));
}

Widget listenKeyboardDown(List<int> keys, VoidCallback onEvent) {
  return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        CustomRawKeyEventDataAndroid _d =
            CustomRawKeyEventDataAndroid.format(event.data);
        if (event.runtimeType == RawKeyDownEvent) {
          keys.contains(_d.keyCode)
              ? onEvent()
              : developer.log(event.physicalKey.toStringShort());
        }
      },
      child: Container());
}
