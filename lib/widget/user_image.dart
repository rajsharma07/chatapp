import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class User_Image extends StatefulWidget {
  User_Image({super.key, required this.onPicImage});
  final void Function(File picked) onPicImage;
  @override
  State<User_Image> createState() {
    return _User_Image();
  }
}

class _User_Image extends State<User_Image> {
  File? _pickedImage;
  void _pickImage() async {
    var xfile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (xfile == null) {
      return;
    }
    setState(() {
      _pickedImage = File(xfile.path);
    });
    widget.onPicImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImage == null ? null : FileImage(_pickedImage!),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.add_a_photo),
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        )
      ],
    );
  }
}
