import 'package:flutter/material.dart';

/// A screen that displays an interactive foot diagram with 16 tappable areas
/// to match the design shown in the image.
class FootMappingScreen extends StatefulWidget {
  const FootMappingScreen({Key? key}) : super(key: key);

  @override
  State<FootMappingScreen> createState() => _FootMappingScreenState();
}

class _FootMappingScreenState extends State<FootMappingScreen> {
  /// Track which foot-area IDs are selected (e.g., ["F0", "F2"]).
  List<String> _selectedAreas = [];

  List<String> get selectedAreas => _selectedAreas;

  set selectedAreas(List<String> value) {
    setState(() {
      _selectedAreas = value;
    });
  }

  // Create a global key for the foot widget to access its state
  final GlobalKey<_FootSelectionWidgetState> _footWidgetKey =
      GlobalKey<_FootSelectionWidgetState>();

  void clearAllSelections() {
    setState(() {
      _selectedAreas = [];
    });
    // Clear selection in the foot widget
    _footWidgetKey.currentState?.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive padding
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "SENSARS",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 22, // Slightly larger
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.info_outline,
              color: const Color(0xFF5E8D9B),
              size: 22, // Slightly larger
            ),
            SizedBox(width: 6),
            Text(
              "Connection status",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 15, // Slightly larger
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode selector
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 14), // Slightly larger
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF5E8D9B),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      "Pain relief mode",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF5E8D9B),
                        fontSize: 16, // Slightly larger
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 14), // Slightly larger
                    child: Text(
                      "Walking mode",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16, // Slightly larger
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Instruction text without reset button
          Padding(
            padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 26, // Slightly larger
                bottom: 18), // Slightly larger
            child: Text(
              "Click on the painful areas",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 17, // Slightly larger
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Reset button above the foot container
          Padding(
            padding: EdgeInsets.only(right: horizontalPadding, bottom: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: clearAllSelections,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7), // Slightly larger
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.grey,
                        size: 19, // Slightly larger
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15, // Slightly larger
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Foot diagram container - dynamically sized
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the available space
                  final availableWidth =
                      constraints.maxWidth - (horizontalPadding * 2);
                  final availableHeight = constraints.maxHeight;

                  // Determine the container size while preserving aspect ratio
                  double containerWidth, containerHeight;

                  // Original aspect ratio of foot image plus some padding
                  const aspectRatio = 343 / 364;

                  // Add a bit more space around the container
                  const paddingFactor =
                      0.95; // 95% of the calculated size to add some space

                  if (availableWidth / availableHeight > aspectRatio) {
                    // Height constrained
                    containerHeight = availableHeight * paddingFactor;
                    containerWidth = containerHeight * aspectRatio;
                  } else {
                    // Width constrained
                    containerWidth = availableWidth * paddingFactor;
                    containerHeight = containerWidth / aspectRatio;
                  }

                  return Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.5, // Slightly thicker border
                      ),
                      borderRadius:
                          BorderRadius.circular(10), // Slightly larger radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FootSelectionWidget(
                      key: _footWidgetKey,
                      onSelectionChanged: (List<String> newSelection) {
                        setState(() {
                          _selectedAreas = newSelection;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Foot pagination
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0), // Slightly larger
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36, // Slightly larger
                  height: 36, // Slightly larger
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF0F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.grey,
                    size: 22, // Slightly larger
                  ),
                ),
                const SizedBox(width: 22), // Slightly larger
                Text(
                  "Right foot 1 / 2",
                  style: TextStyle(
                    color: const Color(0xFF5E8D9B),
                    fontWeight: FontWeight.w500,
                    fontSize: 17, // Slightly larger
                  ),
                ),
                const SizedBox(width: 22), // Slightly larger
                Container(
                  width: 36, // Slightly larger
                  height: 36, // Slightly larger
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF0F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 22, // Slightly larger
                  ),
                ),
              ],
            ),
          ),

          // Confirmation button
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 18.0), // Slightly larger
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8C9CE),
                foregroundColor: Colors.white,
                elevation: 1, // Slight elevation
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Slightly larger radius
                ),
                padding: EdgeInsets.symmetric(vertical: 18), // Slightly larger
              ),
              onPressed: _selectedAreas.isNotEmpty ? () {} : null,
              child: Text(
                "I have inserted all locations where I feel pain",
                style: TextStyle(
                  fontSize: 15, // Slightly larger
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple data class for each tappable foot area.
class _FootArea {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  const _FootArea({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// An interactive foot widget with 16 rectangular hotspots (F0..F15).
/// Tapping toggles selection and highlights the area.
/// The user never sees "F0..F15" labels, but the IDs are returned in a callback.
class FootSelectionWidget extends StatefulWidget {
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> initialSelection;

  const FootSelectionWidget({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [],
  }) : super(key: key);

  @override
  State<FootSelectionWidget> createState() => _FootSelectionWidgetState();
}

class _FootSelectionWidgetState extends State<FootSelectionWidget> {
  late List<String> _selectedAreas;

  // Original foot area coordinates as requested
  final List<_FootArea> _footAreas = const [
    _FootArea(id: 'F0', left: 127, top: 60, width: 24, height: 13),
    _FootArea(id: 'F1', left: 127, top: 75, width: 24, height: 13),
    //
    _FootArea(id: 'F2', left: 157, top: 65, width: 12, height: 10),
    _FootArea(id: 'F3', left: 173, top: 71, width: 12, height: 9),
    _FootArea(id: 'F4', left: 185, top: 85, width: 12, height: 9),
    _FootArea(id: 'F5', left: 202, top: 97, width: 12, height: 9),
    //
    _FootArea(id: 'F6', left: 128, top: 104, width: 24, height: 33),
    _FootArea(id: 'F7', left: 156, top: 104, width: 26, height: 33),
    _FootArea(id: 'F8', left: 187, top: 119, width: 26, height: 20),
    //
    _FootArea(id: 'F9', left: 156, top: 143, width: 26, height: 82),
    _FootArea(id: 'F10', left: 185, top: 143, width: 26, height: 27),
    _FootArea(id: 'F11', left: 185, top: 172, width: 20, height: 27),
    _FootArea(id: 'F12', left: 185, top: 201, width: 20, height: 27),
    //
    _FootArea(id: 'F13', left: 154, top: 235, width: 26, height: 30),
    _FootArea(id: 'F14', left: 154, top: 268, width: 26, height: 35),
    _FootArea(id: 'F15', left: 185, top: 250, width: 18, height: 40),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAreas = List<String>.from(widget.initialSelection);
  }

  // Add the clearSelection method
  void clearSelection() {
    setState(() {
      _selectedAreas.clear();
    });
    widget.onSelectionChanged(_selectedAreas);
  }

  void _onAreaTapped(String areaId) {
    setState(() {
      if (_selectedAreas.contains(areaId)) {
        _selectedAreas.remove(areaId);
      } else {
        _selectedAreas.add(areaId);
      }
    });
    // Return the updated list of selected areas.
    widget.onSelectionChanged(_selectedAreas);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The actual size available.
        final actualWidth = constraints.maxWidth;
        final actualHeight = constraints.maxHeight;

        // Calculate scale factors based on the original dimensions
        final scaleX = actualWidth / 343;
        final scaleY = actualHeight / 364;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Center the foot diagram with optimal padding
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/foot_diagram.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Show all tappable areas with light pink color (visible but subtle)
            ..._footAreas.map((area) {
              // Scale each area's coordinates.
              final double left = area.left * scaleX;
              final double top = area.top * scaleY;
              final double w = area.width * scaleX;
              final double h = area.height * scaleY;

              return Positioned(
                left: left,
                top: top,
                width: w,
                height: h,
                child: GestureDetector(
                  onTap: () => _onAreaTapped(area.id),
                  child: Container(
                    decoration: BoxDecoration(
                      // Areas are invisible until clicked, then show transparent blue
                      color: _selectedAreas.contains(area.id)
                          ? Colors.blue
                              .withOpacity(0.4) // Selected: transparent blue
                          : Colors
                              .transparent, // Unselected: completely invisible
                      // Remove the border that would make areas visible when not selected
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
