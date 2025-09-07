/// Represents an executable command in the command palette.
class Command {
  /// Display name of the command.
  final String title;

  /// Optional description for additional context.
  final String? description;

  /// Callback executed when the command is selected.
  final void Function() action;

  /// Creates a new [Command].
  const Command({
    required this.title,
    this.description,
    required this.action,
  });
}

