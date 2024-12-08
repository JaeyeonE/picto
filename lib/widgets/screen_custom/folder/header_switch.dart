import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class HeaderSwitch extends StatelessWidget {
  HeaderSwitch({super.key});

  final FolderViewModel viewModel = Get.find<FolderViewModel>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: '사진',
                  isSelected: true,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: '채팅',
                  isSelected: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
  }) {
    return Obx(() {
      final isActive = isSelected ? viewModel.isPhotoMode : !viewModel.isPhotoMode;
      
      return GestureDetector(
        onTap: viewModel.toggleViewMode,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }
}