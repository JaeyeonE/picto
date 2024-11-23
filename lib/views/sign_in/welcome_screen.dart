// // lib/views/sign_in/welcome_screen.dart
// import 'package:flutter/material.dart';
// import '../../utils/app_color.dart';
// import 'login_screen.dart';

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               const Spacer(),
//               Center(
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       'assets/sign_in/picto_logo.png',
//                       width: 200,
//                       height: 200,
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'PICTO에 오신 것을\n환영합니다',
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.headlineLarge,
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56),
//                 ),
//                 child: const Text('시작하기'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }