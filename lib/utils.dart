import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static toastMessage(String msg) {
    Fluttertoast.showToast(msg: msg);
  }
}
