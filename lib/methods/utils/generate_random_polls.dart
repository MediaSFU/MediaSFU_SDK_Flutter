import 'dart:math';

/// Generates random seed polls for testing purposes.
///
/// [numberOfPolls] is the number of seed polls to generate.
/// Returns a list of poll objects containing question, type, options, votes, and status.
List<Map<String, dynamic>> generateRandomPolls(int numberOfPolls) {
  final List<String> pollTypes = ['trueFalse', 'yesNo', 'custom'];
  final List<Map<String, dynamic>> polls = [];

  for (int i = 0; i < numberOfPolls; i++) {
    final String type = pollTypes[Random().nextInt(pollTypes.length)];
    List<String> options;

    switch (type) {
      case 'trueFalse':
        options = ['True', 'False'];
        break;
      case 'yesNo':
        options = ['Yes', 'No'];
        break;
      case 'custom':
        options = List<String>.generate(
            Random().nextInt(5) + 2, (idx) => 'Option ${idx + 1}');
        break;
      default:
        options = [];
    }

    final Map<String, dynamic> poll = {
      'id': i + 1, // Incremental number as ID
      'question': 'Random Question ${i + 1}',
      'type': type,
      'options': options,
      'votes': List<int>.filled(options.length, 0),
      'status': 'inactive', // or 'active'
      'voters': {},
    };

    polls.add(poll);
  }

  return polls;
}
