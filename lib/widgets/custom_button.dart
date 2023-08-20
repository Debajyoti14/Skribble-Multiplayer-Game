// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:neopop/utils/color_utils.dart';

class CustomNeoPopButton extends StatelessWidget {
  final void Function()? onPress;
  final String labelText;
  const CustomNeoPopButton({
    Key? key,
    this.onPress,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeoPopButton(
      color: Colors.black,
      bottomShadowColor: ColorUtils.getVerticalShadow(Colors.green).toColor(),
      rightShadowColor: ColorUtils.getHorizontalShadow(Colors.green).toColor(),
      animationDuration: const Duration(milliseconds: 500),
      onTapUp: onPress,
      border: Border.all(
        color: Colors.green,
        width: 2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(labelText, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
