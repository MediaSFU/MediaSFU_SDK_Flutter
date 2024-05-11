import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../../methods/co_host_methods/modify_co_host_settings.dart'
    show modifyCoHostSettings;

/// CoHostModal - A modal widget for managing co-host settings.
///
/// This widget displays a modal for managing co-host settings, allowing users
/// to select a co-host, assign responsibilities, and save the changes.
///
/// Required parameters:
/// - [isCoHostModalVisible]: A boolean to control the visibility of the co-host modal.
/// - [onCoHostClose]: A function to handle closing the co-host modal.
/// - [participants]: The list of participants in the meeting.
/// - [coHostResponsibility]: The list of co-host responsibilities.
/// - [parameters]: Additional parameters for co-host modal functionality.
///
/// Optional parameters:
/// - [onModifyCoHostSettings]: A function to modify co-host settings. Defaults to `modifyCoHostSettings`.
/// - [currentCohost]: The current co-host. Defaults to 'No coHost'.
/// - [position]: The position of the modal. Defaults to 'topRight'.
/// - [backgroundColor]: The background color of the modal. Defaults to Color(0xFF83C0E9).
///
/// Example:
/// ```dart
/// CoHostModal(
///   isCoHostModalVisible: true,
///   onCoHostClose: () {
///     // Close co-host modal logic
///   },
///   participants: [...],
///   coHostResponsibility: [...],
///   parameters: {...},
/// );
/// ```

class CoHostModal extends StatefulWidget {
  final bool isCoHostModalVisible;
  final VoidCallback onCoHostClose;
  final Function({required Map<String, dynamic> parameters})
      onModifyCoHostSettings;
  final String currentCohost;
  final List<dynamic> participants;
  final List<dynamic> coHostResponsibility;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const CoHostModal({
    super.key,
    required this.isCoHostModalVisible,
    required this.onCoHostClose,
    this.onModifyCoHostSettings = modifyCoHostSettings,
    this.currentCohost = 'No coHost',
    required this.participants,
    required this.coHostResponsibility,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });

  @override
  // ignore: library_private_types_in_public_api
  _CoHostModalState createState() => _CoHostModalState();
}

class _CoHostModalState extends State<CoHostModal> {
  late String selectedCohost;
  late Map<String, dynamic> responsibilities;
  late List coHostResponsibilityCopy;
  late String position;

  @override
  void initState() {
    super.initState();
    selectedCohost = widget.currentCohost;
    coHostResponsibilityCopy = List.from(widget.coHostResponsibility);
    responsibilities = widget.coHostResponsibility.fold<Map<String, dynamic>>(
      {},
      (acc, item) {
        final str = item['name'];
        final str2 = _capitalize(str);
        final keyed = 'manage$str2';
        acc[keyed] = item['value'];
        acc['dedicateTo$keyed'] = item['dedicated'];
        return acc;
      },
    );
  }

  String _capitalize(String input) {
    return input.substring(0, 1).toUpperCase() + input.substring(1);
  }

  void handleToggleSwitch(String responsibility) {
    // Extract the responsibility name and lowercase the first letter
    String responsibilityName = '';
    if (responsibility.startsWith('dedicateTo')) {
      responsibilityName =
          responsibility.replaceAll('dedicateToManage', '').toLowerCase();
    } else if (responsibility.startsWith('manage')) {
      responsibilityName =
          responsibility.replaceAll('manageManage', '').toLowerCase();
    }

    // Find the index of the item in the coHostResponsibilityCopy list
    int index = coHostResponsibilityCopy
        .indexWhere((item) => item['name'] == responsibilityName);
    // Check if the responsibility starts with 'dedicateTo'
    if (responsibility.startsWith('dedicateTo')) {
      // Toggle the 'dedicated' property of the item
      if (coHostResponsibilityCopy[index]['dedicated'] == true) {
        coHostResponsibilityCopy[index]['dedicated'] = false;
      } else {
        coHostResponsibilityCopy[index]['dedicated'] = true;
      }
    } else if (responsibility.startsWith('manage')) {
      // Toggle the 'value' property of the item
      coHostResponsibilityCopy[index]['value'] =
          !coHostResponsibilityCopy[index]['value'];
    }

    // Update the state by creating a new list with the modified item
    setState(() {
      coHostResponsibilityCopy = List.from(coHostResponsibilityCopy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> responsibilityItems = [
      {'name': 'manageParticipants', 'label': 'Manage Participants'},
      {'name': 'manageMedia', 'label': 'Manage Media'},
      {'name': 'manageWaiting', 'label': 'Manage Waiting Room'},
      {'name': 'manageChat', 'label': 'Manage Chat'},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.85 * screenWidth;
    if (modalWidth > 450) {
      modalWidth = 450;
    }
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    final filteredParticipants = widget.participants
        .where((participant) => participant['islevel'] != '2');

    return Visibility(
      visible: widget.isCoHostModalVisible,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              top: getModalPosition(
                  widget.position, context, modalWidth, modalHeight)['top'],
              right: getModalPosition(
                  widget.position, context, modalWidth, modalHeight)['right'],
              child: AnimatedContainer(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
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
                          color: widget.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  onPressed: widget.onCoHostClose,
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DropdownButton<String>(
                                value: selectedCohost,
                                onChanged: (String? newValue) {
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
                                      .map<DropdownMenuItem<String>>(
                                    (participant) {
                                      return DropdownMenuItem<String>(
                                        value: participant['name'],
                                        child: Text(participant['name']),
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
                            const Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text('Responsibility',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Select',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Dedicated',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 20,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: responsibilityItems.length,
                              itemBuilder: (context, index) {
                                final item = responsibilityItems[index];

                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        item['label']!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Switch(
                                        value: responsibilities[
                                                'manage${_capitalize(item['name']!)}'] ??
                                            false,
                                        onChanged: (value) {
                                          setState(() {
                                            responsibilities[
                                                    'manage${_capitalize(item['name']!)}'] =
                                                value;
                                            if (!value) {
                                              responsibilities[
                                                      'dedicateToManage${_capitalize(item['name']!)}'] =
                                                  false;
                                              handleToggleSwitch(
                                                  'manage${_capitalize(item['name']!)}');
                                            } else {
                                              handleToggleSwitch(
                                                  'manage${_capitalize(item['name']!)}');
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Switch(
                                        value: responsibilities[
                                                'dedicateToManage${_capitalize(item['name']!)}'] ??
                                            false,
                                        onChanged: (value) {
                                          if (responsibilities[
                                                  'manage${_capitalize(item['name']!)}'] ==
                                              true) {
                                            setState(() {
                                              responsibilities[
                                                      'dedicateToManage${_capitalize(item['name']!)}'] =
                                                  value;
                                            });
                                            handleToggleSwitch(
                                                'dedicateTo${_capitalize(item['name']!)}');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 0,
                              height: 10,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                widget.onModifyCoHostSettings(
                                  parameters: {
                                    ...widget.parameters,
                                    'selectedParticipant': selectedCohost,
                                    'coHost': widget.currentCohost,
                                    'coHostResponsibility':
                                        coHostResponsibilityCopy,
                                    'responsibilities': responsibilities,
                                  },
                                );
                              },
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
}
