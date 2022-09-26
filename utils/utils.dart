import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Image.asset(
            "assets/icons/logo.png",
            width: MediaQuery.of(context).size.width*0.1,
            ),
          Text(text),
        ],
      ),duration: Duration(milliseconds: 2000),
    ),
  );
}

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 100 , maxHeight: 400  , maxWidth: 400);

  if (_file != null) {
    return await _file.readAsBytes();
  }else{
    print('이미지가 선택 되지 않았습니다.');
  }
}
