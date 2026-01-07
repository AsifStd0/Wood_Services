import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/seller_login.dart/seller_login_provider.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';

class SellerLogin extends StatefulWidget {
  const SellerLogin({super.key});

  @override
  State<SellerLogin> createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // ✅ FIX 2: Check login after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkExistingLogin();
      }
    });
  }

  void _initializeAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  // ✅ FIX 3: Updated method to use context properly
  Future<void> _checkExistingLogin() async {
    final viewModel = context.read<SellerAuthProvider>();

    // ✅ FIX 4: Use the new method
    final isLoggedIn = await viewModel.checkExistingLogin();

    if (isLoggedIn && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainSellerScreen()));
    }
  }

  Future<void> _submitLogin() async {
    log('1️⃣ Submit button pressed');

    if (!_formKey.currentState!.validate()) {
      log('❌ Form validation failed');
      return;
    }

    final viewModel = context.read<SellerAuthProvider>();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    log('2️⃣ Attempting login for: $email');

    // Clear previous errors
    viewModel.clearMessages();

    log('3️⃣ Calling viewModel.login()');
    final result = await viewModel.login(email: email, password: password);

    log('4️⃣ Login result: ${result.isRight() ? "SUCCESS" : "FAILURE"}');

    result.fold(
      (failure) {
        log('❌ Login failed: ${failure.message}');
      },
      (authResponse) async {
        log('✅ Login successful');

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          log('5️⃣ Navigating to MainSellerScreen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainSellerScreen()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.brightOrange.withOpacity(0.06), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 28.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Stack(
                  children: [
                    // Main content
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildCard(context),
                      ),
                    ),

                    // Bottom signup text
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: AuthBottomText(
                          questionText: "Don't have an account? ",
                          actionText: "Sign Up",
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => SellerSignupScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Consumer<SellerAuthProvider>(
      builder: (context, viewModel, child) {
        return Card(
          elevation: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 56),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppColors.brightOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brightOrange.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.storefront_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'Welcome Seller',
                            type: CustomTextType.headingLittleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Login to continue your future journey',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Show error/success messages
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (viewModel.successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              viewModel.successMessage!,
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icon(Icons.email, color: AppColors.grey),
                        textInputType: TextInputType.emailAddress,
                        validator: (value) => viewModel.validateEmail(value),
                        onChanged: (value) => viewModel.clearMessages(),
                        focusNode: _emailFocusNode,
                      ),
                      const SizedBox(height: 14),

                      // Password
                      CustomTextFormField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.grey),
                        obscureText: viewModel.obscurePassword,
                        validator: (value) => viewModel.validatePassword(value),
                        onChanged: (value) => viewModel.clearMessages(),
                        focusNode: _passwordFocusNode,
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            viewModel.togglePasswordVisibility();
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => BuyerForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.brightOrange),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey)),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// class SellerLogin extends StatefulWidget {
//   const SellerLogin({super.key});

//   @override
//   State<SellerLogin> createState() => _SellerLoginState();
// }

// class _SellerLoginState extends State<SellerLogin>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FocusNode _emailFocusNode = FocusNode();
//   final FocusNode _passwordFocusNode = FocusNode();

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//   SellerAuthProvider? _viewModel;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();

//     // Schedule check for after Provider is available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _viewModel != null) {
//         _checkExistingLogin();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 420),
//     );

//     _fadeAnim = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeInOut,
//     );

//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.02),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

//     _animController.forward();
//   }

//   Future<void> _checkExistingLogin() async {
//     if (_viewModel == null) return;

//     final isLoggedIn = await _viewModel!.checkExistingLogin();
//     if (isLoggedIn && mounted) {
//       Navigator.of(
//         context,
//       ).pushReplacement(MaterialPageRoute(builder: (_) => MainSellerScreen()));
//     }
//   }

//   Future<void> _submitLogin() async {
//     log('1️⃣ Submit button pressed');

//     if (!_formKey.currentState!.validate()) {
//       log('❌ Form validation failed');
//       return;
//     }

//     // ✅ Use the stored _viewModel instead of context.read
//     if (_viewModel == null) {
//       log('❌ ViewModel not available');
//       return;
//     }

//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     log('2️⃣ Attempting login for: $email');

//     // Clear previous errors
//     _viewModel!.clearMessages();

//     log('3️⃣ Calling viewModel.login()');
//     final result = await _viewModel!.login(email: email, password: password);

//     log('4️⃣ Login result: ${result.isRight() ? "SUCCESS" : "FAILURE"}');

//     result.fold(
//       (failure) {
//         log('❌ Login failed: ${failure.message}');
//       },
//       (authResponse) async {
//         log(
//           '✅ Login successful for: ${authResponse.seller.personalInfo.fullName}',
//         );

//         await Future.delayed(const Duration(milliseconds: 500));

//         if (mounted) {
//           log('5️⃣ Navigating to MainSellerScreen');
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (_) => MainSellerScreen()),
//           );
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => SellerAuthProvider(locator<SellerAuthService>()),
//       builder: (context, child) {
//         // ✅ Store ViewModel reference
//         _viewModel ??= context.read<SellerAuthProvider>();

//         // ✅ Schedule login check after ViewModel is available
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _viewModel != null) {
//             _checkExistingLogin();
//           }
//         });

//         return Scaffold(
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.brightOrange.withOpacity(0.06),
//                   Colors.white,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: SafeArea(
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20.0,
//                     vertical: 28.0,
//                   ),
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 520),
//                     child: Stack(
//                       children: [
//                         // Main content
//                         SlideTransition(
//                           position: _slideAnim,
//                           child: FadeTransition(
//                             opacity: _fadeAnim,
//                             child: _buildCard(context),
//                           ),
//                         ),

//                         // Bottom signup text
//                         Positioned(
//                           bottom: 0,
//                           left: 0,
//                           right: 0,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 14.0),
//                             child: AuthBottomText(
//                               questionText: "Don't have an account? ",
//                               actionText: "Sign Up",
//                               onPressed: () {
//                                 // context.go('/seller_signup');
//                                 Navigator.of(context).pushReplacement(
//                                   MaterialPageRoute(
//                                     builder: (_) {
//                                       return SellerSignupScreen();
//                                     },
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCard(BuildContext context) {
//     return Consumer<SellerAuthProvider>(
//       builder: (context, viewModel, child) {
//         return Card(
//           elevation: 18,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           shadowColor: Colors.black.withOpacity(0.06),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 56),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 54,
//                       width: 54,
//                       decoration: BoxDecoration(
//                         color: AppColors.brightOrange,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.brightOrange.withOpacity(0.18),
//                             blurRadius: 10,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Icon(
//                           Icons.storefront_outlined,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomText(
//                             'Welcome Seller',
//                             type: CustomTextType.headingLittleLarge,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             'Login to continue your future journey',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 22),

//                 // Show error/success messages
//                 if (viewModel.errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.red.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             color: Colors.red,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               viewModel.errorMessage!,
//                               style: TextStyle(color: Colors.red),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 if (viewModel.successMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: Colors.green.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.check_circle,
//                             color: Colors.green,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               viewModel.successMessage!,
//                               style: TextStyle(color: Colors.green),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       // Email
//                       CustomTextFormField(
//                         controller: _emailController,
//                         hintText: 'Email Address',
//                         prefixIcon: Icon(Icons.email, color: AppColors.grey),
//                         textInputType: TextInputType.emailAddress,
//                         validator: (value) => viewModel.validateEmail(value),
//                         onChanged: (value) => viewModel.clearMessages(),
//                         focusNode: _emailFocusNode,
//                       ),
//                       const SizedBox(height: 14),

//                       // Password
//                       CustomTextFormField(
//                         controller: _passwordController,
//                         hintText: 'Password',
//                         prefixIcon: Icon(Icons.lock, color: AppColors.grey),
//                         obscureText: viewModel.obscurePassword,
//                         validator: (value) => viewModel.validatePassword(value),
//                         onChanged: (value) => viewModel.clearMessages(),
//                         focusNode: _passwordFocusNode,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             viewModel.obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: AppColors.grey,
//                           ),
//                           onPressed: () {
//                             // ✅ FIX: Use togglePasswordVisibility instead of setObscurePassword
//                             viewModel.togglePasswordVisibility();
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       // Forgot password
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             // context.go('/buyer_forgot');
//                             Navigator.of(context).pushReplacement(
//                               MaterialPageRoute(
//                                 builder: (_) {
//                                   return BuyerForgotPassword();
//                                 },
//                               ),
//                             );
//                           },
//                           child: Text(
//                             'Forgot Password?',
//                             style: TextStyle(color: AppColors.brightOrange),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       // Login button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: viewModel.isLoading ? null : _submitLogin,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.brightOrange,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: viewModel.isLoading
//                               ? SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 )
//                               : Text(
//                                   'Login',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 18),

//                       // Divider with text
//                       Row(
//                         children: [
//                           Expanded(child: Divider(color: AppColors.grey)),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12.0,
//                             ),
//                             child: Text(
//                               'Or continue with',
//                               style: TextStyle(
//                                 color: AppColors.grey,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                           Expanded(child: Divider(color: AppColors.grey)),
//                         ],
//                       ),

//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


// ! *******

                  // // Social buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           // TODO: wire Google sign-in
                  //         },
                  //         icon: const Icon(Icons.apple, size: 20),
                  //         label: Text(
                  //           'Google',
                       
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: BorderSide(color: Colors.grey.shade300),
                  //           backgroundColor: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           // TODO: wire Apple sign-in
                  //         },
                  //         icon: const Icon(Icons.apple, size: 20),
                  //         label: Text(
                  //           'Apple',
                  //           //   style: AppCustomTextStyle.bodyText(context)
                  //           //       .copyWith(color: Colors.black87),
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: BorderSide(color: Colors.grey.shade300),
                  //           backgroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
               
               