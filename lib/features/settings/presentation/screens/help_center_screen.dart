import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.helpCenter),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: const [
          _FaqItem(
            question: 'How do I post a listing?',
            answer: 'Tap the + button on the home screen and fill in your item details.',
          ),
          _FaqItem(
            question: 'Is there any fee?',
            answer: 'No! Nearend is completely free. No commission or fees.',
          ),
          _FaqItem(
            question: 'How do I contact a seller?',
            answer: 'Open a listing and tap "Contact Seller" to start a chat.',
          ),
          _FaqItem(
            question: 'How is my location used?',
            answer: "Location is used to show nearby items. It's never shared without consent.",
          ),
          _FaqItem(
            question: 'How do I delete my account?',
            answer: 'Go to Settings → Privacy Policy or contact us at support@nearend.app.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.md, 0, AppDimensions.md, AppDimensions.md,
          ),
          child: Text(answer),
        ),
      ],
    );
  }
}
