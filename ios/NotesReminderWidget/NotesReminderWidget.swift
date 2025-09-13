import WidgetKit
import SwiftUI

struct NoteEntry: TimelineEntry {
    let date: Date
    let note: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: Date(), note: "No notes")
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> ()) {
        let entry = NoteEntry(date: Date(), note: loadNote())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> ()) {
        let entry = NoteEntry(date: Date(), note: loadNote())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func loadNote() -> String {
        let defaults = UserDefaults(suiteName: "group.com.example.pandora")
        return defaults?.string(forKey: "note") ?? "No notes"
    }
}

struct NotesReminderWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.note)
            .padding()
    }
}

@main
struct NotesReminderWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NotesReminderWidget", provider: Provider()) { entry in
            NotesReminderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Notes Reminder")
        .description("Shows the next upcoming note.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
