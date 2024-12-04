///Users/jaeyeon/workzone/picto/lib/widgets/common/map_header.dart

import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';

class MapHeader extends StatelessWidget {
  final VoidCallback? onSearchPressed;
  
  const MapHeader({
    super.key,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'PICTO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: onSearchPressed,  // 변경된 부분
          ),
        ],
      ),
    );
  }
}