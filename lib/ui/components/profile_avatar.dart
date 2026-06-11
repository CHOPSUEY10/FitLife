import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final double iconSize;

  const ProfileAvatar({
    super.key,
    this.radius = 22,
    this.iconSize = 24,
  });

  static final ValueNotifier<String?> imagePathNotifier = ValueNotifier<String?>(null);

  static Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('profile_image_path');
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          imagePathNotifier.value = savedPath;
        } else {
          imagePathNotifier.value = null;
        }
      } else {
        imagePathNotifier.value = null;
      }
    } catch (e) {
      debugPrint('Error loading avatar: $e');
    }
  }

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  void initState() {
    super.initState();
    ProfileAvatar.loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ProfileAvatar.imagePathNotifier,
      builder: (context, imagePath, child) {
        if (imagePath != null) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundImage: FileImage(File(imagePath)),
          );
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.grey[800],
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: widget.iconSize,
          ),
        );
      },
    );
  }
}
