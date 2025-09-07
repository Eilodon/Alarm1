class NoteAnalysis {
  final String summary;
  final List<String> actionItems;
  final List<String> suggestedTags;
  final String? suggestedTitle;
  final List<DateTime> dates;

  NoteAnalysis({
    required this.summary,
    required this.actionItems,
    required this.suggestedTags,
    required this.dates,
    this.suggestedTitle,
  });
}
