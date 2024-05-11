import 'package:flutter/material.dart';
import '../../consumers/generate_page_content.dart' show generatePageContent;

/// Pagination - A widget for displaying pagination controls.
///
/// This widget allows you to display pagination controls for navigating through pages.
/// It provides options to control the appearance and behavior of the pagination controls.
///
/// The total number of pages.
/// final int totalPages;
///
/// The current page index.
/// final int currentUserPage;
///
/// The position of the pagination controls.
/// Defaults to 'middle' if not provided.
/// final String position;
///
/// The location of the pagination controls.
/// Defaults to 'bottom' if not provided.
/// final String location;
///
/// The direction of pagination controls.
/// Defaults to 'horizontal' if not provided.
/// final String direction;
///
/// Custom constraints for the buttons container.
/// final BoxConstraints? buttonsContainerStyle;
///
/// An alternate icon component to use for the pagination controls.
/// final Widget? alternateIconComponent;
///
/// The icon component to use for the pagination controls.
/// final Widget? iconComponent;
///
/// The color of the active page indicator.
/// Defaults to Color(0xFF2c678f) if not provided.
/// final Color activePageColor;
///
/// The color of the inactive page indicators.
/// Defaults to null if not provided.
/// final Color? inactivePageColor;
///
/// The background color of the pagination controls.
/// Defaults to Color(0xFFFFFFFF) if not provided.
/// final Color backgroundColor;
///
/// The height of the pagination controls.
/// Defaults to 40.0 if not provided.
/// final double paginationHeight;
///
/// A flag indicating whether to show the pagination controls.
/// Defaults to true if not provided.
/// final bool showAspect;
///
/// Additional parameters to pass for page content generation.
/// final Map<String, dynamic> parameters;

typedef GeneratePageContent = Future<void> Function(
    {required int page, required Map<String, dynamic> parameters});

typedef HandlePageChange = void Function(int page);

class Pagination extends StatelessWidget {
  final int totalPages;
  final int currentUserPage;
  // HandlePageChange handlePageChange;
  final String position;
  final String location;
  final String direction;
  final BoxConstraints? buttonsContainerStyle;
  final Widget? alternateIconComponent;
  final Widget? iconComponent;
  final Color activePageColor;
  final Color? inactivePageColor;
  final Color backgroundColor;
  final double paginationHeight;
  final bool showAspect;
  final Map<String, dynamic> parameters;

  const Pagination({
    super.key,
    required this.totalPages,
    required this.currentUserPage,
    // required this.handlePageChange,
    this.position = 'middle',
    this.location = 'bottom',
    this.direction = 'horizontal',
    this.buttonsContainerStyle,
    this.alternateIconComponent,
    this.iconComponent,
    this.activePageColor = const Color(0xFF2c678f),
    this.inactivePageColor,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.paginationHeight = 40.0,
    this.showAspect = true,
    required this.parameters,
  });

  void handlePageChange(int page) async {
    // Generate the content for the current page
    await generatePageContent(page: page, parameters: parameters);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> data = List<int>.generate(totalPages + 1, (index) => index);

    return Visibility(
      visible: showAspect,
      child: Container(
        color: backgroundColor,
        constraints: BoxConstraints(
          maxHeight:
              direction == 'vertical' ? double.infinity : paginationHeight,
          maxWidth:
              direction == 'horizontal' ? double.infinity : paginationHeight,
        ),
        child: Center(
          child: ListView.builder(
            shrinkWrap:
                true, // Ensures the ListView only occupies the space needed
            scrollDirection:
                direction == 'vertical' ? Axis.vertical : Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final isActive = data[index] == currentUserPage;
              final pageStyle = isActive
                  ? BoxDecoration(color: activePageColor)
                  : BoxDecoration(
                      color: inactivePageColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ));

              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    handlePageChange(data[index]);
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: pageStyle,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: pageStyle,
                    child: Center(
                      child: data[index] == 0
                          ? Icon(Icons.star,
                              size: 18,
                              color: isActive ? Colors.yellow : Colors.grey)
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                '${data[index]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
