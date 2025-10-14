import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';

class UploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileTypeNote;

  const UploadBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileTypeNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(title, type: CustomTextType.subtitleMedium),
        const SizedBox(height: 8),
        DottedBorder(
          options: RectDottedBorderOptions(
            dashPattern: [5, 3],
            strokeWidth: 1.5,
            color: AppColors.grey,
          ),
          child: Container(
            height: 150,
            width: double.infinity,
            color: AppColors.buttonLavender,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: "Click to upload ",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: "or drag and drop",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileTypeNote,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
