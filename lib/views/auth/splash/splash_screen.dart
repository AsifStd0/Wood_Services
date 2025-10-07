import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/constant/image_paths.dart';
import 'package:wood_service/core/theme/app_test_style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bottom image
          GestureDetector(
            onTap: () {
              context.push('/slides');
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(AssetImages.blackChair, fit: BoxFit.cover),
            ),
          ),

          // Center content slightly above center
          Align(
            alignment: const Alignment(0, -0.3), // 👈 moves it a bit up
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AssetImages.simpleSofa, width: 60, height: 60),
                const SizedBox(height: 12),
                CustomText(
                  'FURNI EXPO',
                  type: CustomTextType.mainheadingLarge,
                  fontSize: 36,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:wood_service/core/constant/image_paths.dart';
// import 'package:wood_service/core/theme/app_test_style.dart';

// class SelectionScreen extends StatelessWidget {
//   const SelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Bottom image
//           GestureDetector(
//             onTap: () {
//               context.push('/slides');
//             },
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Image.asset(AssetImages.blackChair, fit: BoxFit.cover),
//             ),
//           ),

//           // Center content slightly above center
//           Align(
//             alignment: const Alignment(0, -0.3), // 👈 moves it a bit up
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(AssetImages.simpleSofa, width: 60, height: 60),
//                 const SizedBox(height: 12),
//                 CustomText(
//                   'FurniFind',
//                   type: CustomTextType.mainheadingLarge,
//                   fontSize: 36,
//                 ),
//                 CustomText(
//                   'Furni Perfect Furniture',
//                   type: CustomTextType.mainheadingLarge,
//                   fontSize: 36,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

