import '../../types/types.dart' show Poll, ShowAlert, PollUpdatedData;
import 'package:flutter/foundation.dart';

/// Defines options for updating poll information.
class PollUpdatedOptions {
  final PollUpdatedData data;
  final List<Poll> polls;
  Poll? poll;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final void Function(List<Poll>) updatePolls;
  final void Function(Poll) updatePoll;
  final void Function(bool) updateIsPollModalVisible;

  PollUpdatedOptions({
    required this.data,
    required this.polls,
    this.poll,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.updatePolls,
    required this.updatePoll,
    required this.updateIsPollModalVisible,
  });
}

/// Type definition for the function that updates poll information.
typedef PollUpdatedType = Future<void> Function(PollUpdatedOptions options);

/// Updates the poll state based on the provided options.
///
/// This function checks the poll's status and updates the state accordingly.
/// If a new poll starts, it displays an alert and opens the poll modal for eligible members.
///
/// Parameters:
/// - [options]: The [PollUpdatedOptions] containing details such as the poll data, member level,
///   and update functions for the poll state.
///
/// Example:
/// ```dart
/// final options = PollUpdatedOptions(
///   data: PollUpdatedData(poll: updatedPoll, status: "started"),
///   polls: currentPolls,
///   poll: currentPoll,
///   member: "user123",
///   islevel: "1",
///   showAlert: (alert) => print(alert.message),
///   updatePolls: (updatedPolls) => setPolls(updatedPolls),
///   updatePoll: (updatedPoll) => setCurrentPoll(updatedPoll),
///   updateIsPollModalVisible: (visible) => setIsPollModalVisible(visible),
/// );
///
/// await pollUpdated(options);
/// ```

Future<void> pollUpdated(PollUpdatedOptions options) async {
  try {
    List<Poll> polls = options.polls;
    Poll poll = options.poll ?? Poll(question: '', options: [], id: '');

    if (options.data.polls != null) {
      polls = options.data.polls ?? [];
      options.updatePolls(polls);
    } else {
      polls = [options.data.poll];
      options.updatePolls(polls);
    }

    Poll tempPoll = Poll(
        id: '', question: '', options: [], status: '', type: '', votes: []);
    if (poll.id != '') {
      tempPoll = poll;
    }

    if (options.data.status != 'ended') {
      poll = options.data.poll;
      options.updatePoll(poll);
    }

    if (options.data.status == 'started' && options.islevel != '2') {
      if (poll.voters == null ||
          (poll.voters is Map && !poll.voters!.containsKey(options.member))) {
        options.showAlert?.call(
          message: 'New poll started',
          type: 'success',
          duration: 3000,
        );
        options.updateIsPollModalVisible(true);
      }
    } else if (options.data.status == 'ended') {
      if (tempPoll.id == options.data.poll.id) {
        options.showAlert?.call(
          message: 'Poll ended',
          type: 'danger',
          duration: 3000,
        );
        options.updatePoll(options.data.poll);
      }
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      print('Error updating poll: $error');
      print('Stacktrace: $stackTrace');
    }
  }
}
