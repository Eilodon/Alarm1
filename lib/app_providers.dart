import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'features/note/presentation/note_provider.dart';

/// Wraps the given [child] with all application level providers.
class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteProvider>(create: (_) => NoteProvider()),
        // Additional providers can be added here.
      ],
      child: child,
    );
  }
}
