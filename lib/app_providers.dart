import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'features/note/presentation/note_provider.dart';
import 'features/note/data/calendar_service.dart';
import 'features/note/data/notification_service.dart';
import 'features/note/data/home_widget_service.dart';
import 'features/backup/data/note_sync_service.dart';
import 'package:alarm_data/alarm_data.dart';

/// Wraps the given [child] with all application level providers.
class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteProvider>(
          create: (_) {
            final repo = NoteRepositoryImpl();
            return NoteProvider(
              repository: repo,
              calendarService: CalendarServiceImpl.instance,
              notificationService: NotificationServiceImpl(),
              homeWidgetService: const HomeWidgetServiceImpl(),
              syncService: NoteSyncServiceImpl(repository: repo),
            );
          },
        ),
        // Additional providers can be added here.
      ],
      child: child,
    );
  }
}
