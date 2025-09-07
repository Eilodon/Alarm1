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
        Provider<data.DbService>(create: (_) => data.DbService()),
        Provider<domain.BackupService>(create: (_) => data.BackupService()),
        Provider<domain.NoteRepository>(
          create: (context) => data.NoteRepositoryImpl(
            dbService: context.read<data.DbService>(),
            backupService: context.read<domain.BackupService>()
                as data.BackupService,
          ),
        ),
        Provider<domain.GetNotes>(
          create: (context) => domain.GetNotes(
            context.read<domain.NoteRepository>(),
          ),
        ),
        Provider<domain.SaveNotes>(
          create: (context) => domain.SaveNotes(
            context.read<domain.NoteRepository>(),
          ),
        ),
        Provider<domain.UpdateNote>(
          create: (context) => domain.UpdateNote(
            context.read<domain.NoteRepository>(),
          ),
        ),
        Provider<domain.AutoBackup>(
          create: (context) => domain.AutoBackup(
            context.read<domain.NoteRepository>(),
          ),
        ),
        Provider<domain.NoteSyncService>(
          create: (context) => NoteSyncServiceImpl(
            repository: context.read<domain.NoteRepository>(),
          ),
        ),
        Provider<SettingsService>(
          create: (_) => SettingsServiceImpl(),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (context) => NoteProvider(
            getNotes: context.read<domain.GetNotes>(),
            saveNotes: context.read<domain.SaveNotes>(),
            updateNote: context.read<domain.UpdateNote>(),
            autoBackup: context.read<domain.AutoBackup>(),
            calendarService: CalendarServiceImpl.instance,
            notificationService: NotificationServiceImpl(),
            homeWidgetService: const HomeWidgetServiceImpl(),
            syncService: context.read<domain.NoteSyncService>(),
          ),
        ),
        // Additional providers can be added here.
      ],
      child: child,
    );
  }
}
