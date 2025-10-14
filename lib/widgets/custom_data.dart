// import 'package:flutter/material.dart';
// import 'package:wood_service/core/constant/image_paths.dart';
// import 'package:wood_service/core/theme/app_colors.dart';
// import 'package:wood_service/core/theme/app_test_style.dart';

// class RememberForgot extends StatefulWidget {
//   final bool initialRememberValue;
//   final ValueChanged<bool>? onRememberChanged;
//   final VoidCallback? onForgotPassword;
//   final String rememberText;
//   final String forgotText;
//   final Color rememberTextColor;
//   final Color forgotTextColor;
//   final double textSize;
//   final double checkboxRadius;

//   const RememberForgot({
//     super.key,
//     this.initialRememberValue = false,
//     this.onRememberChanged,
//     this.onForgotPassword,
//     this.rememberText = "Remember me",
//     this.forgotText = "Forgot Password?",
//     this.rememberTextColor = Colors.grey,
//     this.forgotTextColor = Colors.orange,
//     this.textSize = 14,
//     this.checkboxRadius = 5.0,
//   });

//   @override
//   State<RememberForgot> createState() => _RememberForgotState();
// }

// class _RememberForgotState extends State<RememberForgot> {
//   late bool isRemembered;

//   @override
//   void initState() {
//     super.initState();
//     isRemembered = widget.initialRememberValue;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Remember Me with circular checkbox
//         Row(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   isRemembered = !isRemembered;
//                 });
//                 widget.onRememberChanged?.call(isRemembered);
//               },
//               child: Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   // shape: BoxShape.circle,
//                   borderRadius: BorderRadius.circular(widget.checkboxRadius),

//                   border: Border.all(
//                     color:
//                         // isRemembered
//                         //     ? Theme.of(context).primaryColor
//                         // :
//                         Colors.grey,
//                     width: 1,
//                   ),
//                   color: isRemembered
//                       ? Theme.of(context).primaryColor
//                       : Colors.transparent,
//                 ),
//                 child: isRemembered
//                     ? Icon(Icons.check, size: 20, color: AppColors.brightOrange)
//                     : null,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               widget.rememberText,
//               style: TextStyle(
//                 color: widget.rememberTextColor,
//                 fontSize: widget.textSize,
//               ),
//             ),
//           ],
//         ),

//         // Forgot Password
//         GestureDetector(
//           onTap: widget.onForgotPassword,
//           child: Text(
//             widget.forgotText,
//             style: TextStyle(
//               color: widget.forgotTextColor,
//               fontSize: widget.textSize,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class WelcomeFurni extends StatelessWidget {
//   final VoidCallback onBack;

//   const WelcomeFurni({super.key, required this.onBack});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 240,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // 🔸 Image on Right
//           Align(
//             alignment: Alignment.centerRight,
//             child: Container(
//               color: AppColors.chairBackColor,
//               child: Image.asset(
//                 AssetImages.lightOrangeSofa,
//                 width: 200,
//                 height: double.infinity,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),

//           // 🔹 Back Button on Top Left
//           Positioned(
//             top: 0,
//             left: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.grey, width: 1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.black),
//                 onPressed: onBack,
//               ),
//             ),
//           ),

//           // 🔹 Static Text on Bottom Left
//           Positioned(
//             left: 0,
//             bottom: 35,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomText('Welcome to', type: CustomTextType.headingSmall),
//                 CustomText('FURNI EXPO', type: CustomTextType.mainheadingLarge),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
