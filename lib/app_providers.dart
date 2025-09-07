import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'features/note/presentation/note_provider.dart';
import 'features/note/data/calendar_service.dart';
import 'features/note/data/notification_service.dart';
import 'features/note/data/home_widget_service.dart';
import 'features/backup/data/note_sync_service.dart';
import 'package:alarm_data/alarm_data.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'features/settings/domain/settings_service.dart';
import 'features/settings/data/settings_service.dart';

/// Wraps the given [child] with all application level providers.
class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DbService>(create: (_) => DbService()),
        Provider<BackupService>(create: (_) => BackupService()),
        Provider<NoteRepository>(
          create: (context) => NoteRepositoryImpl(
            dbService: context.read<DbService>(),
            backupService: context.read<BackupService>(),
          ),
        ),
        Provider<GetNotes>(
          create: (context) => GetNotes(context.read<NoteRepository>()),
        ),
        Provider<SaveNotes>(
          create: (context) => SaveNotes(context.read<NoteRepository>()),
        ),
        Provider<UpdateNote>(
          create: (context) => UpdateNote(context.read<NoteRepository>()),
        ),
        Provider<AutoBackup>(
          create: (context) => AutoBackup(context.read<NoteRepository>()),
        ),
        Provider<NoteSyncService>(
          create: (context) => NoteSyncServiceImpl(
            repository: context.read<NoteRepository>(),
          ),
        ),
        Provider<SettingsService>(
          create: (_) => SettingsServiceImpl(),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (context) => NoteProvider(
            getNotes: context.read<GetNotes>(),
            saveNotes: context.read<SaveNotes>(),
            updateNote: context.read<UpdateNote>(),
            autoBackup: context.read<AutoBackup>(),
            calendarService: CalendarServiceImpl.instance,
            notificationService: NotificationServiceImpl(),
            homeWidgetService: const HomeWidgetServiceImpl(),
            syncService: context.read<NoteSyncService>(),
          ),
        ),
        // Additional providers can be added here.
      ],
      child: child,
    );
  }
}
