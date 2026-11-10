import 'package:flutter/material.dart';

import 'analytics.dart';
import 'site_theme.dart';

class AnalyticsPreferences extends StatelessWidget {
  const AnalyticsPreferences({
    super.key,
    required this.consent,
    required this.onChoice,
    this.onClose,
  });

  final AnalyticsConsent consent;
  final ValueChanged<bool> onChoice;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Material(
    color: surface,
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      consent == AnalyticsConsent.unknown
                          ? 'Allow analytics?'
                          : 'Analytics settings',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      tooltip: 'Close analytics settings',
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'We use Google Analytics cookies to understand visits and contact clicks. '
                'Usage data is sent to Google, with advertising features disabled. '
                'You can change your choice in Analytics settings at the bottom of the page.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              Wrap(
                spacing: 16,
                children: [
                  TextButton(
                    onPressed: () => onChoice(true),
                    child: Text(
                      consent == AnalyticsConsent.granted
                          ? 'Keep analytics on'
                          : 'Allow analytics',
                    ),
                  ),
                  TextButton(
                    onPressed: () => onChoice(false),
                    child: Text(
                      consent == AnalyticsConsent.granted
                          ? 'Disable analytics'
                          : 'No thanks',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
