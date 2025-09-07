import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';

import '../features/settings/domain/settings_service.dart';
import 'package:provider/provider.dart';


class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_PageData> _pages = [
    _PageData(
      Icons.note,
      (l10n) => l10n.onboardingTakeNotes,
      (l10n) => l10n.onboardingTakeNotesDesc,
    ),
    _PageData(
      Icons.alarm,
      (l10n) => l10n.onboardingSetReminders,
      (l10n) => l10n.onboardingSetRemindersDesc,
    ),
    _PageData(
      Icons.settings,
      (l10n) => l10n.onboardingCustomize,
      (l10n) => l10n.onboardingCustomizeDesc,
    ),
  ];

  Future<void> _finish() async {
    await context.read<SettingsService>().saveHasSeenOnboarding(true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finish,
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(page.icon, size: 120),
                const SizedBox(height: 24),
                Text(
                  page.title(l10n),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  page.description(l10n),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _currentPage == _pages.length - 1
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _finish,
                child: Text(l10n.onboardingGetStarted),
              ),
            )
          : null,
    );
  }
}

class _PageData {
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) description;
  const _PageData(this.icon, this.title, this.description);
}
