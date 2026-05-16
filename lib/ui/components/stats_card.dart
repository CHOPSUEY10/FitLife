import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final Color valueColor;
  final String iconPath;
  final Widget? customProgress;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.backgroundColor,
    required this.titleColor,
    required this.valueColor,
    required this.iconPath,
    this.customProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 16,
                height: 16,
                color: titleColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: valueColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
          if (customProgress != null) ...[
            const SizedBox(height: 8),
            customProgress!,
          ],
        ],
      ),
    );
  }
}
