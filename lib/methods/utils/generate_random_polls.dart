import 'dart:math';
import '../../types/types.dart' show Poll;

/// Class to hold options for generating a random poll list.
class GenerateRandomPollsOptions {
  final int numberOfPolls;

  GenerateRandomPollsOptions({required this.numberOfPolls});
}

typedef GenerateRandomPollsType = List<Poll> Function(
    GenerateRandomPollsOptions options);

/// Generates a list of random polls for testing.
///
/// ### Parameters:
/// - `options` (`GenerateRandomPollsOptions`): Contains:
///   - `numberOfPolls` (`int`): The desired number of polls to generate.
///
/// ### Workflow:
/// 1. **Poll Type Selection**:
///    - Randomly selects a poll type (`trueFalse`, `yesNo`, or `custom`).
///
/// 2. **Options Generation**:
///    - Depending on the poll type, generates appropriate options:
///      - `trueFalse`: Options are `["True", "False"]`.
///      - `yesNo`: Options are `["Yes", "No"]`.
///      - `custom`: Generates between 2 and 6 custom options.
///
/// 3. **Poll Creation**:
///    - Creates a new `Poll` object with the following properties:
///      - `id`: Unique ID based on the index.
///      - `question`: Sample question text.
///      - `type`: Poll type.
///      - `options`: Options for voting.
///      - `votes`: Initializes votes for each option to zero.
///      - `status`: Defaults to `'inactive'`.
///      - `voters`: Initializes with an empty voter map.
///
/// 4. **Return Value**:
///    - Returns a list of generated `Poll` objects.
///
/// ### Example Usage:
/// ```dart
/// final polls = generateRandomPolls(GenerateRandomPollsOptions(numberOfPolls: 5));
/// print(polls);  // Outputs a list of 5 random Poll objects.
/// ```
///
/// ### Returns:
/// - A `List<Poll>` containing randomly generated polls.

List<Poll> generateRandomPolls(GenerateRandomPollsOptions options) {
  final List<String> pollTypes = ['trueFalse', 'yesNo', 'custom'];
  final List<Poll> polls = [];

  for (int i = 0; i < options.numberOfPolls; i++) {
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
          Random().nextInt(5) + 2,
          (idx) => 'Option ${idx + 1}',
        );
        break;
      default:
        options = [];
    }

    final poll = Poll(
      id: '${i + 1}', // String ID for consistency
      question: 'Random Question ${i + 1}',
      type: type,
      options: options,
      votes: List<int>.filled(options.length, 0),
      status: 'inactive', // or 'active'
      voters: {},
    );

    polls.add(poll);
  }

  return polls;
}
