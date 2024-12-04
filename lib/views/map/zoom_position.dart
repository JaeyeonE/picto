//lib/views/map/zoom_position.dart

import 'package:flutter/material.dart';

class LocationLevelIndicator extends StatelessWidget {
  final String locationType;

  const LocationLevelIndicator({
    Key? key, 
    required this.locationType
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String levelText;
    switch (locationType) {
      case 'small':
        levelText = '읍/면/동 수준';
        break;
      case 'middle':
        levelText = '시/군/구 수준';
        break;
      case 'large':
        levelText = '도/광역시 수준';
        break;
      default:
        levelText = '알 수 없는 수준';
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(137, 179, 0, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          levelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}