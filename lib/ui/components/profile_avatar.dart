import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final double iconSize;

  const ProfileAvatar({
    Key? key,
    this.radius = 22,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('profile_image_path');
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          if (mounted) {
            setState(() {
              _imagePath = savedPath;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imagePath != null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: FileImage(File(_imagePath!)),
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
  }
}
