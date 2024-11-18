import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        Participant,
        Stream,
        ProcessConsumerTransportsAudioType,
        ProcessConsumerTransportsAudioParameters,
        TransportType,
        BreakoutParticipant,
        EventType,
        ProcessConsumerTransportsAudioOptions;

// Define ResumePauseAudioStreamsParameters class
abstract class ResumePauseAudioStreamsParameters
    implements ProcessConsumerTransportsAudioParameters {
  // Properties as abstract getters
  List<List<BreakoutParticipant>> get breakoutRooms;
  List<Participant> get refParticipants;
  List<Stream> get allAudioStreams;
  List<Participant> get participants;
  String get islevel;
  EventType get eventType;
  List<TransportType> get consumerTransports;
  List<BreakoutParticipant> get limitedBreakRoom;
  int get hostNewRoom;
  String get member;

  // Update function as abstract getter
  void Function(List<BreakoutParticipant>) get updateLimitedBreakRoom;

  // Mediasfu functions as abstract getters
  ProcessConsumerTransportsAudioType get processConsumerTransportsAudio;

  // Method to get updated parameters
  ResumePauseAudioStreamsParameters Function() get getUpdatedAllParams;
}

// Define ResumePauseAudioStreamsOptions class
class ResumePauseAudioStreamsOptions {
  final int? breakRoom;
  final bool? inBreakRoom;
  final ResumePauseAudioStreamsParameters parameters;

  ResumePauseAudioStreamsOptions({
    this.breakRoom,
    this.inBreakRoom,
    required this.parameters,
  });
}

typedef ResumePauseAudioStreamsType = Future<void> Function(
    {required ResumePauseAudioStreamsOptions options});

/// Resumes or pauses audio streams for participants based on breakout room status and event type.
///
/// This function determines which audio streams to resume or pause based on the breakout room status,
/// user level, and event type. It manages host audio requirements for "conference" events and adds
/// host audio for "webinar" events if the user is not the host.
///
/// Parameters:
/// - [options] (`ResumePauseAudioStreamsOptions`): The options containing breakout room information,
///   status of the participant in a breakout room, and required parameters for managing audio streams.
///
/// Example:
/// ```dart
/// final options = ResumePauseAudioStreamsOptions(
///   breakRoom: 1,
///   inBreakRoom: true,
///   parameters: ResumePauseAudioStreamsParameters(
///     breakoutRooms: [[BreakoutParticipant(name: "Alice", breakRoom: 1)], [BreakoutParticipant(name: "Bob", breakRoom: 2)]],
///     refParticipants: [Participant(name: "Alice", audioID: "audio1", videoID: "video1"), Participant(name: "Bob", audioID: "audio2", videoID: "video2")],
///     allAudioStreams: [Stream(producerId: "audio1"), Stream(producerId: "audio2")],
///     participants: [Participant(name: "Host", islevel: "2", audioID: "hostAudio")],
///     islevel: "1",
///     eventType: EventType.webinar,
///     consumerTransports: [],
///     limitedBreakRoom: [],
///     hostNewRoom: 0,
///     member: "Alice",
///     updateLimitedBreakRoom: (List<BreakoutParticipant> room) => print("Room updated"),
///     processConsumerTransportsAudio: ({required List<dynamic> consumerTransports, required List<Stream> lStreams, required Map<String, dynamic> parameters}) async {
///       // Define behavior for processing consumer transports here
///     },
///     getUpdatedAllParams: () => this, // Replace with actual implementation for updated parameters
///   ),
/// );
///
/// await resumePauseAudioStreams(options: options);
/// ```

Future<void> resumePauseAudioStreams({
  required ResumePauseAudioStreamsOptions options,
}) async {
  // Retrieve parameters from options
  var parameters = options.parameters.getUpdatedAllParams();

  final breakoutRooms = parameters.breakoutRooms;
  final refParticipants = parameters.refParticipants;
  final allAudioStreams = parameters.allAudioStreams;
  final participants = parameters.participants;
  final islevel = parameters.islevel;
  final eventType = parameters.eventType;
  final consumerTransports = parameters.consumerTransports;
  final hostNewRoom = parameters.hostNewRoom;
  final member = parameters.member;

  final updateLimitedBreakRoom = parameters.updateLimitedBreakRoom;
  final processConsumerTransportsAudio =
      parameters.processConsumerTransportsAudio;

  List<BreakoutParticipant> room = [];
  List<Stream> currentStreams = [];
  final int breakRoom = options.breakRoom ?? -1;
  final bool inBreakRoom = options.inBreakRoom ?? false;

  // Determine the room based on breakout status
  if (inBreakRoom && breakRoom != -1) {
    room = breakoutRooms[breakRoom];
  } else {
    room = refParticipants
        .where((participant) => !breakoutRooms
            .expand((x) => x)
            .map((obj) => obj.name)
            .contains(participant.name))
        .map((participant) => BreakoutParticipant(
              name: participant.name,
              breakRoom: participant.breakRoom,
            ))
        .toList();
  }
  updateLimitedBreakRoom(room);

  try {
    bool addHostAudio = false;

    if (islevel != '2' && eventType == EventType.conference) {
      final roomMember = breakoutRooms
          .firstWhere((r) => r.any((p) => p.name == member), orElse: () => []);
      int memberBreakRoom =
          roomMember.isNotEmpty ? breakoutRooms.indexOf(roomMember) : -1;

      if ((inBreakRoom && breakRoom != hostNewRoom) ||
          (!inBreakRoom &&
              hostNewRoom != -1 &&
              hostNewRoom != memberBreakRoom)) {
        final host = participants.firstWhere((obj) => obj.islevel == '2',
            orElse: () => Participant(audioID: '', videoID: '', name: ''));
        if (host.name.isNotEmpty) {
          room = room
              .where((participant) => participant.name != host.name)
              .toList();
        }
      } else if ((inBreakRoom && breakRoom == hostNewRoom) ||
          (!inBreakRoom && hostNewRoom == -1) ||
          (!inBreakRoom &&
              hostNewRoom == memberBreakRoom &&
              memberBreakRoom != -1)) {
        addHostAudio = true;
      }
    }

    // Add streams of participants in the room
    for (var participant in room) {
      var streams = allAudioStreams.where((stream) {
        var producerId =
            stream.producerId.isNotEmpty ? stream.producerId : stream.audioID;
        return producerId != null &&
            refParticipants.any(
                (p) => p.audioID == producerId && p.name == participant.name);
      }).toList();
      currentStreams.addAll(streams);
    }

    // If webinar, add the host audio stream if it is not in the currentStreams
    if (islevel != '2' && (eventType == EventType.webinar || addHostAudio)) {
      final host = participants.firstWhere((obj) => obj.islevel == '2',
          orElse: () => Participant(audioID: '', videoID: '', name: ''));
      final hostStream = allAudioStreams.firstWhere(
          (obj) => obj.producerId == host.audioID && host.audioID.isNotEmpty,
          orElse: () => Stream(producerId: ''));
      if (hostStream.producerId.isNotEmpty &&
          !currentStreams.contains(hostStream)) {
        currentStreams.add(hostStream);
        if (!room.map((obj) => obj.name).contains(host.name)) {
          room.add(BreakoutParticipant(name: host.name, breakRoom: -1));
        }
        updateLimitedBreakRoom(room);
      }
    }

    final optionsProcess = ProcessConsumerTransportsAudioOptions(
      consumerTransports: consumerTransports,
      lStreams: currentStreams,
      parameters: parameters,
    );
    await processConsumerTransportsAudio(
      optionsProcess,
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error in resumePauseAudioStreams: $error');
    }
  }
}
