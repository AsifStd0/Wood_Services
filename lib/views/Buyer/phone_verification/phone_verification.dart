import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/buyer_main.dart';
import 'package:wood_service/widgets/custom_button.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<PhoneVerificationScreen> {
  TextEditingController codeController = TextEditingController();
  int _seconds = 30; // countdown timer
  late Timer _timer;
  bool _isResendAvailable = false;

  final Color accentColor = const Color(0xFFD97A28); // orange button color

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 30;
    _isResendAvailable = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
        setState(() {
          _isResendAvailable = true;
        });
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verification",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              "We sent a verification code to",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const Text(
              "elena.garcia@email.com",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // PIN input boxes
            PinCodeTextField(
              appContext: context,
              length: 5,
              controller: codeController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              cursorColor: Colors.black87,
              backgroundColor: AppColors.white,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 45,
                inactiveColor: Colors.grey.shade300,
                selectedColor: accentColor,
                activeColor: accentColor,
              ),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            // Resend section
            Center(
              child: Column(
                children: [
                  const Text(
                    "Didn’t receive code?",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _isResendAvailable ? _startTimer : null,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: "Resend in ",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          TextSpan(
                            text: _isResendAvailable
                                ? "Resend Now"
                                : '$_seconds',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Change phone/email",
                      style: TextStyle(
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Verify button
            // Verify button
            CustomButtonUtils.login(
              title: 'Verify',
              backgroundColor: AppColors.brightOrange,
              onPressed: () {
                // context.push('/main_buyer');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return BuyerMainScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
