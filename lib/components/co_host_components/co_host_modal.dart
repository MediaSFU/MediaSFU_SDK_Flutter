import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/co_host_methods/modify_co_host_settings.dart'
    show
        modifyCoHostSettings,
        ModifyCoHostSettingsOptions,
        ModifyCoHostSettingsType;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show Participant, CoHostResponsibility, ShowAlert;

/// Configuration options for the `CoHostModal` widget.
///
/// Example:
/// ```dart
/// CoHostModal(
///   options: CoHostModalOptions(
///     isCoHostModalVisible: true,
///     onCoHostClose: () {
///       // Logic for closing the modal
///     },
///     participants: participantsList,
///     coHostResponsibility: responsibilitiesList,
///     roomName: "MyRoom",
///     socket: mySocket,
///     updateCoHostResponsibility: (newResponsibilities) => print(newResponsibilities),
///     updateCoHost: (coHost) => print("Updated co-host: $coHost"),
///     updateIsCoHostModalVisible: (isVisible) => print("Modal visibility: $isVisible"),
///   ),
/// );
/// ```
class CoHostModalOptions {
  /// Determines if the co-host modal is visible.
  final bool isCoHostModalVisible;

  /// Function to handle closing the co-host modal.
  final VoidCallback onCoHostClose;

  /// Function to modify co-host settings.
  final ModifyCoHostSettingsType onModifyCoHostSettings;

  /// Current co-host name.
  final String currentCohost;

  /// List of participants in the meeting.
  final List<Participant> participants;

  /// List of co-host responsibilities.
  final List<CoHostResponsibility> coHostResponsibility;

  /// Position of the modal ('topLeft', 'topRight', 'bottomLeft', 'bottomRight').
  final String position;

  /// Background color of the modal.
  final Color backgroundColor;

  /// Name of the room.
  final String roomName;

  /// Function to display alerts.
  final ShowAlert? showAlert;

  /// Update function for co-host responsibilities.
  final Function(List<CoHostResponsibility>) updateCoHostResponsibility;

  /// Update function for co-host.
  final Function(String) updateCoHost;

  /// Update function for co-host modal visibility.
  final Function(bool) updateIsCoHostModalVisible;

  /// Socket instance for real-time communication.
  final io.Socket? socket;

  CoHostModalOptions({
    required this.isCoHostModalVisible,
    required this.onCoHostClose,
    this.onModifyCoHostSettings = modifyCoHostSettings,
    this.currentCohost = 'No coHost',
    required this.participants,
    required this.coHostResponsibility,
    this.position = 'topRight',
    this.backgroundColor = const Color.fromARGB(255, 179, 214, 237),
    required this.roomName,
    this.showAlert,
    required this.updateCoHostResponsibility,
    required this.updateCoHost,
    required this.updateIsCoHostModalVisible,
    this.socket,
  });
}

typedef CoHostModalType = Widget Function(
    {required CoHostModalOptions options});

/// CoHostModal - A modal widget for managing co-host settings.
///
/// This widget displays a modal for managing co-host settings, allowing users
/// to select a co-host, assign responsibilities, and save the changes.
///
/// Example:
/// ```dart
/// CoHostModal(
///   options: CoHostModalOptions(
///     isCoHostModalVisible: true,
///     onCoHostClose: () {
///       // Close co-host modal logic
///     },
///     participants: [...],
///     coHostResponsibility: [...],
///     parameters: {...},
///   ),
/// )
/// ```
class CoHostModal extends StatefulWidget {
  final CoHostModalOptions options;

  const CoHostModal({
    super.key,
    required this.options,
  });

  @override
  _CoHostModalState createState() => _CoHostModalState();
}

class _CoHostModalState extends State<CoHostModal> {
  late String selectedCohost;
  late List<CoHostResponsibility> coHostResponsibilityCopy;
  late Map<String, bool> responsibilities;

  @override
  void initState() {
    super.initState();
    selectedCohost = widget.options.currentCohost;
    coHostResponsibilityCopy = List.from(widget.options.coHostResponsibility);
    responsibilities = _initializeResponsibilities(coHostResponsibilityCopy);
  }

  /// Initializes the responsibilities map based on the list of responsibilities.
  Map<String, bool> _initializeResponsibilities(
      List<CoHostResponsibility> responsibilitiesList) {
    Map<String, bool> map = {};
    for (var responsibility in responsibilitiesList) {
      String capitalizedName = _capitalize(responsibility.name);
      map['manage$capitalizedName'] = responsibility.value;
      map['dedicateToManage$capitalizedName'] = responsibility.dedicated;
    }
    return map;
  }

  /// Capitalizes the first letter of a given string.
  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Handles toggling of switches for responsibilities.
  void handleToggleSwitch(String key) {
    if (!mounted) return;
    setState(() {
      responsibilities[key] = !responsibilities[key]!;
      _updateResponsibilityList(key);
    });
  }

  /// Updates the co-host responsibility list based on the toggled key.
  void _updateResponsibilityList(String key) {
    String responsibilityName = '';
    bool? newValue;

    if (key.startsWith('dedicateToManage')) {
      responsibilityName = key.replaceAll('dedicateToManage', '').toLowerCase();
      newValue = responsibilities[key];
      _setCoHostResponsibilityValue(responsibilityName,
          dedicated: newValue ?? false);
    } else if (key.startsWith('manage')) {
      responsibilityName = key.replaceAll('manage', '').toLowerCase();
      newValue = responsibilities[key];
      _setCoHostResponsibilityValue(responsibilityName,
          value: newValue ?? false);
      if (!newValue!) {
        // If manage is turned off, also turn off dedicateToManage
        String dedicatedKey =
            'dedicateToManage${_capitalize(responsibilityName)}';
        responsibilities[dedicatedKey] = false;
        _setCoHostResponsibilityValue(responsibilityName, dedicated: false);
      }
    }
  }

  /// Updates the co-host responsibility list based on changes.
  void _setCoHostResponsibilityValue(String name,
      {bool? value, bool? dedicated}) {
    int index =
        coHostResponsibilityCopy.indexWhere((item) => item.name == name);
    if (index != -1) {
      if (value != null) coHostResponsibilityCopy[index].value = value;
      if (dedicated != null) {
        coHostResponsibilityCopy[index].dedicated = dedicated;
      }
    }
  }

  /// Saves the modified co-host settings.
  void _saveCoHostSettings() {
    widget.options.onModifyCoHostSettings(
      ModifyCoHostSettingsOptions(
        roomName: widget.options.roomName,
        showAlert: widget.options.showAlert,
        selectedParticipant: selectedCohost,
        coHost: widget.options.currentCohost,
        coHostResponsibility: coHostResponsibilityCopy,
        updateCoHostResponsibility: widget.options.updateCoHostResponsibility,
        updateCoHost: widget.options.updateCoHost,
        updateIsCoHostModalVisible: widget.options.updateIsCoHostModalVisible,
        socket: widget.options.socket,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate modal size
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 450 ? 450.0 : 0.85 * screenWidth;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    // Filter participants excluding current co-host and those with islevel '2'
    final filteredParticipants = widget.options.participants.where(
      (participant) => participant.islevel != '2',
    );

    // Ensure selectedCohost is valid, or default to 'No coHost'
    if (filteredParticipants
        .where((participant) => participant.name == selectedCohost)
        .isEmpty) {
      selectedCohost = 'No coHost';
    }

    return Visibility(
      visible: widget.options.isCoHostModalVisible,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              top: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ))['top'],
              right: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ))['right'],
              child: AnimatedContainer(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.options.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(milliseconds: 300),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: modalWidth,
                        height: modalHeight,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.options.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Manage Co-Host',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.options.onCoHostClose,
                                  icon: const Icon(Icons.close),
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 20,
                            ),
                            // Co-Host Selection
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DropdownButton<String>(
                                value: selectedCohost,
                                onChanged: (String? newValue) {
                                  if (!mounted) return;
                                  setState(() {
                                    selectedCohost = newValue!;
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'No coHost',
                                    child: Text('No Co-Host'),
                                  ),
                                  ...filteredParticipants
                                      .toSet()
                                      .map<DropdownMenuItem<String>>(
                                    (participant) {
                                      return DropdownMenuItem<String>(
                                        value: participant.name,
                                        child: Text(participant.name),
                                      );
                                    },
                                  ),
                                ],
                                hint: const Text('Select Co-Host'),
                              ),
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 20,
                            ),
                            // Responsibilities Header
                            const Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    'Responsibility',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Select',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Dedicated',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 20,
                            ),
                            // Responsibilities List
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: coHostResponsibilityCopy.length,
                                itemBuilder: (context, index) {
                                  final responsibility =
                                      coHostResponsibilityCopy[index];
                                  final capitalizedName =
                                      _capitalize(responsibility.name);
                                  final manageKey = 'manage$capitalizedName';
                                  final dedicateKey =
                                      'dedicateToManage$capitalizedName';

                                  return Row(
                                    children: [
                                      // Responsibility Label
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          _formatResponsibilityLabel(
                                              responsibility.name),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      // Manage Switch
                                      Expanded(
                                        flex: 3,
                                        child: Switch(
                                          value: responsibilities[manageKey] ??
                                              false,
                                          onChanged: (value) {
                                            handleToggleSwitch(manageKey);
                                          },
                                        ),
                                      ),
                                      // Dedicate Switch
                                      Expanded(
                                        flex: 3,
                                        child: Switch(
                                          value:
                                              responsibilities[dedicateKey] ??
                                                  false,
                                          onChanged: (value) {
                                            if (responsibilities[manageKey] ==
                                                true) {
                                              handleToggleSwitch(dedicateKey);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 0,
                              height: 10,
                            ),
                            const SizedBox(height: 10),
                            // Save Button
                            ElevatedButton(
                              onPressed: _saveCoHostSettings,
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the responsibility label by replacing camelCase with spaced words.
  String _formatResponsibilityLabel(String name) {
    // Example: 'manageParticipants' -> 'Manage Participants'
    final regex = RegExp(r'(?=[A-Z])');
    final splitName = name.split(regex).join(' ');

    // Capitalize the first letter of the split name
    return splitName[0].toUpperCase() + splitName.substring(1);
  }
}
