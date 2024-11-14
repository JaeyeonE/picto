import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:picto/viewmodles/folder_view_model.dart';

class HeaderSwitch extends StatefulWidget {
  const HeaderSwitch({super.key});

  @override
  State<HeaderSwitch> createState() => _HeaderSwitchState();
}

class _HeaderSwitchState extends State<HeaderSwitch> {

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
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
                    child: GestureDetector(
                      onTap: () => viewModel.toggleMode(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: viewModel.isFirst 
                              ? Colors.white 
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: viewModel.isFirst
                                  ? Colors.blue 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '사진',
                            style: TextStyle(
                              color: viewModel.isFirst
                                  ? Colors.blue 
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.toggleMode(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !viewModel.isFirst
                              ? Colors.white 
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: !viewModel.isFirst 
                                  ? Colors.blue 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '채팅',
                            style: TextStyle(
                              color: !viewModel.isFirst
                                  ? Colors.blue 
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}