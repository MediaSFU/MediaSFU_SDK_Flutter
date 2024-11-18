import 'dart:math';
import '../../types/types.dart' show Request, Participant;

/// Class to hold options for generating a random request list.
class GenerateRandomRequestListOptions {
  final List<Participant> participants;
  final String hostName;
  final String? coHostName;
  final int numberOfRequests;

  GenerateRandomRequestListOptions({
    required this.participants,
    required this.hostName,
    this.coHostName,
    required this.numberOfRequests,
  });
}

typedef GenerateRandomRequestListType = List<Request> Function(
    GenerateRandomRequestListOptions options);

/// Generates a list of random requests for participants, excluding the host and co-host.
///
/// Example usage:
/// ```dart
/// final options = GenerateRandomRequestListOptions(
///   participants: [Participant(id: '1', name: 'Alice'), Participant(id: '2', name: 'Bob'), Participant(id: '3', name: 'Charlie')],
///   hostName: 'Alice',
///   coHostName: 'Bob',
///   numberOfRequests: 2,
/// );
/// List<Request> requestList = generateRandomRequestList(options);
/// print(requestList);
/// ```
List<Request> generateRandomRequestList(
    GenerateRandomRequestListOptions options) {
  // Filter out the host and co-host from the participants
  List<Participant> filteredParticipants = options.participants
      .where((participant) =>
          participant.name != options.hostName &&
          participant.name != options.coHostName)
      .toList();

  // Create a list with three possible request icons
  List<String> requestIcons = ['fa-video', 'fa-desktop', 'fa-microphone'];

  // Shuffle the requestIcons list to ensure unique icons for each participant
  requestIcons.shuffle();

  // Generate unique requests for each participant with unique icons
  List<Request> requestList = [];
  for (var participant in filteredParticipants) {
    Set<String> uniqueIcons = {}; // To ensure unique icons for each participant

    for (int i = 0; i < options.numberOfRequests; i++) {
      String randomIcon;
      do {
        randomIcon = requestIcons[Random().nextInt(requestIcons.length)];
      } while (uniqueIcons.contains(randomIcon));

      uniqueIcons.add(randomIcon);

      requestList.add(Request(
        id: participant.id ?? '',
        name: participant.name.toLowerCase().replaceAll(' ', '_'),
        icon: randomIcon,
        username: participant.name.toLowerCase().replaceAll(' ', '_'),
      ));
    }
  }

  return requestList;
}
