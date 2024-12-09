import 'package:flutter/material.dart';
import 'package:picto/models/user_manager/user.dart';
import 'package:picto/widgets/common/navigation.dart';

class LiveScreen extends StatefulWidget {
  final User initialUser; // Assuming there's a User class

  const LiveScreen({
    super.key, 
    required this.initialUser
  });

  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  int selectedIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          '아직 사진이 덜 모였어요. 다음 시즌에 만나요!',
          style: TextStyle(fontSize: 14),
        ),
      ),
      bottomNavigationBar: RepaintBoundary(
        child: CustomNavigationBar(
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
            if (index == 2 && selectedIndex == 2) {
              
            }
          },
          currentUser: widget.initialUser,
        ),
      ),
    );
  }
}