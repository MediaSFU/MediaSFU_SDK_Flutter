import 'package:flutter/foundation.dart';

typedef ShowAlert = void Function(
    {required String message, required String type, required int duration});
typedef UpdatePolls = void Function(List<dynamic> polls);
typedef UpdatePoll = void Function(Map<String, dynamic> poll);
typedef UpdateIsPollModalVisible = void Function(bool visible);

Future<void> pollUpdated({
  required Map<String, dynamic> data,
  required Map<String, dynamic> parameters,
}) async {
  try {
    List<dynamic> polls = parameters['polls'] ?? [];
    Map<String, dynamic> poll = parameters['poll'] ?? {};
    String member = parameters['member'] ?? '';
    String islevel = parameters['islevel'] ?? '0';
    ShowAlert? showAlert = parameters['showAlert'];
    UpdatePolls updatePolls = parameters['updatePolls'];
    UpdatePoll updatePoll = parameters['updatePoll'];
    UpdateIsPollModalVisible updateIsPollModalVisible =
        parameters['updateIsPollModalVisible'];

    if (data['polls'] != null) {
      polls = data['polls'];
      updatePolls(polls);
    } else {
      polls = [data['poll']];
      updatePolls(polls);
    }

    Map<String, dynamic> tempPoll = {'id': ''};

    if (poll.isNotEmpty) {
      tempPoll = Map<String, dynamic>.from(poll);
    }

    if (data['status'] != 'ended') {
      poll = data['poll'];
      updatePoll(poll);
    }

    if (data['status'] == 'started' && islevel != '2') {
      if (poll['voters'] == null ||
          (poll['voters'] is Map && !poll['voters'].containsKey(member))) {
        showAlert?.call(
            message: 'New poll started', type: 'success', duration: 3000);
        updateIsPollModalVisible(true);
      }
    } else if (data['status'] == 'ended') {
      if (islevel == '2') {
        showAlert?.call(message: 'Poll ended', type: 'danger', duration: 3000);
        updateIsPollModalVisible(false);
      } else {
        if (tempPoll['id'] == data['poll']['id']) {
          showAlert?.call(
              message: 'Poll ended', type: 'danger', duration: 3000);
        }
      }
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      print('Error updating poll: $error');
      print('Stacktrace Poll update: $stackTrace');
    }
  }
}
