import 'dart:math';

/// Generates a list of random requests for participants, excluding the host and co-host.
///
/// The [participants] parameter is a list of dynamic objects representing the participants.
/// The [hostName] parameter is a string representing the name of the host.
/// The [coHostName] parameter is a string representing the name of the co-host.
/// The [numberOfRequests] parameter is an integer representing the number of requests to generate for each participant.
///
/// Returns a list of maps, where each map represents a request and contains the following keys:
/// - 'id': The ID of the participant.
/// - 'name': The lowercase and underscored name of the participant.
/// - 'icon': The randomly selected request icon.
/// - 'username': The lowercase and underscored name of the participant.

List<Map<String, dynamic>> generateRandomRequestList(List<dynamic> participants,
    String hostName, String coHostName, int numberOfRequests) {
  // Filter out the host and co-host from the participants
  List<dynamic> filteredParticipants = participants
      .where((participant) =>
          participant['name'] != hostName && participant['name'] != coHostName)
      .toList();

  // Create a list with three possible request icons
  List<String> requestIcons = ['fa-video', 'fa-desktop', 'fa-microphone'];

  // Shuffle the requestIcons list to ensure unique icons for each participant and randomly select between 1 and 3 icons
  requestIcons.shuffle();

  // Generate unique requests for each participant with unique icons
  List<Map<String, dynamic>> requestList = [];
  for (var participant in filteredParticipants) {
    Set<String> uniqueIcons = {}; // To ensure unique icons for each participant

    for (int i = 0; i < numberOfRequests; i++) {
      String randomIcon;
      do {
        randomIcon = requestIcons[Random().nextInt(requestIcons.length)];
      } while (uniqueIcons.contains(randomIcon));

      uniqueIcons.add(randomIcon);

      requestList.add({
        'id': participant['id'],
        'name': participant['name'].toLowerCase().replaceAll(' ', '_'),
        'icon': randomIcon,
        'username': participant['name'].toLowerCase().replaceAll(' ', '_'),
      });
    }
  }

  return requestList;
}
