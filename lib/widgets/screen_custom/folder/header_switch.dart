import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class HeaderSwitch extends StatelessWidget {
  const HeaderSwitch({super.key});

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
                  context: context,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: '채팅',
                  isSelected: false,
                  context: context,
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
    required BuildContext context,
  }) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
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
      },
    );
  }
}