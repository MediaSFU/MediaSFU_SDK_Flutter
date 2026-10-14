import '../../types/types.dart' show ShowAlert;

/// Options for handling the event when a person joins.
class PersonJoinedOptions {
  final String name;

  /// Readable name to show instead of [name], when known.
  final String? displayName;
  final ShowAlert? showAlert;

  PersonJoinedOptions({
    required this.name,
    this.displayName,
    this.showAlert,
  });
}

typedef PersonJoinedType = void Function(PersonJoinedOptions options);

/// Function that handles a person joining an event.
///
/// This function displays an alert/notification about the person joining the event.
/// It takes a [PersonJoinedOptions] instance, which includes the person's name and an optional [ShowAlert] function
/// to display the alert/notification.
///
/// Example usage:
/// ```dart
/// final options = PersonJoinedOptions(
///   name: "Alice",
///   showAlert: (message: "Alice joined the event.", type: "success", duration: 3000),
/// );
/// personJoined(options);
/// ```
void personJoined(PersonJoinedOptions options) {
  options.showAlert?.call(
    message: '${(options.displayName?.trim().isNotEmpty ?? false) ? options.displayName!.trim() : options.name} has joined the event.',
    type: 'success',
    duration: 3000,
  );
}
