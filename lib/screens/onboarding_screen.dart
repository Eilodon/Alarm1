import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_PageData> _pages = const [
    _PageData(Icons.note, 'Take Notes', 'Write down your thoughts and ideas.'),
    _PageData(Icons.alarm, 'Set Reminders', 'Schedule alarms for important tasks.'),
    _PageData(Icons.settings, 'Customize', 'Adjust themes and font sizes to your liking.'),
  ];

  Future<void> _finish() async {
    await SettingsService().saveHasSeenOnboarding(true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Skip'),
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
                Text(page.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  page.description,
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
                child: const Text('Get Started'),
              ),
            )
          : null,
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String description;
  const _PageData(this.icon, this.title, this.description);
}
