// // lib/views/sign_in/signup_screen.dart
// import 'package:flutter/material.dart';
// import 'package:picto/models/user_modles.dart';
// import '../../services/user_manager.dart';
// import '../../utils/app_color.dart';
// import '../../widgets/common/sign_in_header.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _verificationCodeController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   bool _isLoading = false;
//   bool _isEmailVerified = false;
//   bool _isVerificationSent = false;
//   bool _agreedToTerms = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _verificationCodeController.dispose();
//     super.dispose();
//   }

//   Future<void> _verifyEmail() async {
//     if (_emailController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('이메일을 입력해주세요')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final checkRequest = EmailCheckRequest(email: _emailController.text);
//       final isAvailable = await UserManager().checkEmail(checkRequest);
      
//       if (isAvailable) {
//         setState(() => _isVerificationSent = true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('인증 코드가 전송되었습니다')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _verifyCode() async {
//     // TODO: 실제 인증 코드 확인 로직 구현
//     if (_verificationCodeController.text.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('올바른 인증 코드를 입력해주세요')),
//       );
//       return;
//     }

//     setState(() => _isEmailVerified = true);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('이메일이 인증되었습니다')),
//     );
//   }

//   void _showTermsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('이용약관'),
//         content: const SingleChildScrollView(
//           child: Text('// TODO: 실제 이용약관 내용 추가'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('닫기'),
//           ),
//         ],
//       ),
//     );
//   }



//   Future<void> _handleSignUp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_isEmailVerified) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('이메일 인증이 필요합니다')),
//       );
//       return;
//     }
//     if (!_agreedToTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('이용약관에 동의해주세요')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final signUpRequest = SignUpRequest(
//         email: _emailController.text,
//         password: _passwordController.text,
//         name: _nameController.text,
//         userId: DateTime.now().millisecondsSinceEpoch % 1000000, // 임시 ID 생성
//         lat: 0, // 기본값
//         lng: 0, // 기본값
//       );

//       await UserManager().signUp(signUpRequest);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('회원가입이 완료되었습니다')),
//         );
//         Navigator.of(context).pop(); // 로그인 화면으로 돌아가기
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('회원가입'),
//         leading: IconButton(
//           icon: Image.asset('assets/common/arrow_back_black.png'),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SignInHeader(
//                 title: '계정 만들기',
//                 subtitle: 'PICTO와 함께 특별한 순간을 기록해보세요',
//               ),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: '이름',
//                   hintText: '이름을 입력해주세요',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return '이름을 입력해주세요';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _emailController,
//                       enabled: !_isEmailVerified,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: InputDecoration(
//                         labelText: '이메일',
//                         hintText: 'example@email.com',
//                         suffixIcon: _isEmailVerified
//                             ? const Icon(Icons.check_circle, color: AppColors.success)
//                             : null,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return '이메일을 입력해주세요';
//                         }
//                         if (!value.contains('@')) {
//                           return '올바른 이메일 형식이 아닙니다';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   if (!_isEmailVerified)
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _verifyEmail,
//                       child: Text(_isVerificationSent ? '재전송' : '인증'),
//                     ),
//                 ],
//               ),
//               if (_isVerificationSent && !_isEmailVerified) ...[
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _verificationCodeController,
//                         decoration: const InputDecoration(
//                           labelText: '인증번호',
//                           hintText: '인증번호 6자리를 입력해주세요',
//                         ),
//                         keyboardType: TextInputType.number,
//                         maxLength: 6,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: _verifyCode,
//                       child: const Text('확인'),
//                     ),
//                   ],
//                 ),
//               ],
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: !_isPasswordVisible,
//                 decoration: InputDecoration(
//                   labelText: '비밀번호',
//                   hintText: '8자 이상 입력해주세요',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible 
//                         ? Icons.visibility 
//                         : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return '비밀번호를 입력해주세요';
//                   }
//                   if (value.length < 8) {
//                     return '비밀번호는 8자 이상이어야 합니다';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: !_isConfirmPasswordVisible,
//                 decoration: InputDecoration(
//                   labelText: '비밀번호 확인',
//                   hintText: '비밀번호를 다시 입력해주세요',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isConfirmPasswordVisible 
//                         ? Icons.visibility 
//                         : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return '비밀번호를 다시 입력해주세요';
//                   }
//                   if (value != _passwordController.text) {
//                     return '비밀번호가 일치하지 않습니다';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: _agreedToTerms,
//                     onChanged: (value) {
//                       setState(() {
//                         _agreedToTerms = value ?? false;
//                       });
//                     },
//                     fillColor: MaterialStateProperty.resolveWith((states) {
//                       if (states.contains(MaterialState.selected)) {
//                         return AppColors.primary;
//                       }
//                       return null;
//                     }),
//                   ),
//                   const Text('이용약관에 동의합니다'),
//                   TextButton(
//                     onPressed: _showTermsDialog,
//                     child: Text(
//                       '보기',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _handleSignUp,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text('회원가입'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }