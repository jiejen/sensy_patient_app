import 'package:flutter/material.dart';

/// A screen that displays an interactive foot diagram with 16 tappable areas
/// and UI elements that match the "first screenshot" design.
class FootMappingScreen extends StatefulWidget {
  const FootMappingScreen({Key? key}) : super(key: key);

  @override
  _FootMappingScreenState createState() => _FootMappingScreenState();
}

class _FootMappingScreenState extends State<FootMappingScreen> {
  /// Whether to show a "grid" option (this toggle now does nothing).
  bool showGrid = false;

  /// Track which foot-area IDs are selected (e.g., ["F0", "F2"]).
  List<String> selectedAreas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light background to match your design.
      backgroundColor: const Color(0xFFF5F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1) Top Bar with "Back" and "Running"
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (left)
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios,
                            size: 16, color: Color(0xFF2D4F63)),
                        const SizedBox(width: 4),
                        Text(
                          "Back",
                          style: TextStyle(
                            color: const Color(0xFF2D4F63),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Running pill (right)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Running",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2) Step Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step 1 (Active)
                  _buildStepIndicator(
                    stepNumber: "1",
                    label: "Place of sensations",
                    active: true,
                  ),
                  const SizedBox(width: 16),
                  // Step 2 (Inactive)
                  _buildStepIndicator(
                    stepNumber: "2",
                    label: "Level of sensations",
                    active: false,
                  ),
                ],
              ),
            ),

            // 3) Foot Diagram (Interactive)
            Expanded(
              child: Center(
                child: Container(
                  width: 364, // Adjust container size as needed
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FootSelectionWidget(
                    showGrid:
                        showGrid, // This value is accepted but not used in drawing.
                    onSelectionChanged: (List<String> newSelection) {
                      setState(() {
                        selectedAreas = newSelection;
                      });
                    },
                  ),
                ),
              ),
            ),

            // 4) Pagination / Foot Indicator Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left arrow
                  _circleButton(
                    icon: Icons.arrow_back_ios,
                    onTap: () {
                      // TODO: Switch to "left foot" or previous foot
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Left foot 1 / 2",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  // Right arrow
                  _circleButton(
                    icon: Icons.arrow_forward_ios,
                    onTap: () {
                      // TODO: Switch to "left foot" or next foot
                    },
                  ),
                ],
              ),
            ),

            // 5) "Add sensation level" Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A6470),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                // Disable if nothing is selected
                onPressed: selectedAreas.isEmpty
                    ? null
                    : () {
                        // TODO: Handle "Add sensation level"
                      },
                child: const Text(
                  "Add sensation level",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 6) "Grid" toggle + "Erase" button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Grid toggle (does nothing)
                  Row(
                    children: [
                      const Text("Grid",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: showGrid,
                        activeColor: const Color(0xFF3A6470),
                        onChanged: (bool value) {
                          setState(() {
                            showGrid = value;
                          });
                        },
                      ),
                    ],
                  ),
                  // Erase button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedAreas.clear();
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Erase"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 7) "Don't add anything..." TextButton
            TextButton(
              onPressed: () {
                // TODO: Handle skipping or continuing the stimulation
              },
              child: Text(
                "Don't add anything and continue the stimulation",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Builds a step indicator "pill" for the top row.
  Widget _buildStepIndicator({
    required String stepNumber,
    required String label,
    required bool active,
  }) {
    final Color activeColor = const Color(0xFF3A6470);
    final Color inactiveColor = Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: active ? Colors.white : Colors.grey,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: active ? activeColor : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a small circular button for pagination arrows.
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onTap,
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
  final bool showGrid;

  const FootSelectionWidget({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [],
    this.showGrid = false,
  }) : super(key: key);

  @override
  State<FootSelectionWidget> createState() => _FootSelectionWidgetState();
}

class _FootSelectionWidgetState extends State<FootSelectionWidget> {
  late List<String> _selectedAreas;

  final List<_FootArea> _footAreas = const [
    _FootArea(id: 'F0', left: 124, top: 75, width: 24, height: 13),
    _FootArea(id: 'F1', left: 124, top: 90, width: 24, height: 13),
    _FootArea(id: 'F2', left: 157, top: 80, width: 12, height: 10),
    _FootArea(id: 'F3', left: 173, top: 86, width: 12, height: 9),
    _FootArea(id: 'F4', left: 185, top: 100, width: 12, height: 9),
    _FootArea(id: 'F5', left: 202, top: 112, width: 12, height: 9),
    _FootArea(id: 'F6', left: 126, top: 116, width: 24, height: 30),
    _FootArea(id: 'F7', left: 154, top: 116, width: 26, height: 30),
    _FootArea(id: 'F8', left: 185, top: 129, width: 26, height: 17),
    _FootArea(id: 'F9', left: 154, top: 150, width: 26, height: 73),
    _FootArea(id: 'F10', left: 185, top: 150, width: 26, height: 22),
    _FootArea(id: 'F11', left: 185, top: 174, width: 20, height: 24),
    _FootArea(id: 'F12', left: 185, top: 200, width: 20, height: 23),
    _FootArea(id: 'F13', left: 154, top: 226, width: 26, height: 26),
    _FootArea(id: 'F14', left: 154, top: 255, width: 26, height: 30),
    _FootArea(id: 'F15', left: 185, top: 239, width: 24, height: 30),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAreas = List<String>.from(widget.initialSelection);
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

        // Calculate scale factors.
        final scaleX = actualWidth / 343;
        final scaleY = actualHeight / 364;

        return Stack(
          children: [
            // The background foot diagram.
            Positioned.fill(
              child: Image.asset(
                'assets/foot_diagram.png',
                fit: BoxFit.contain,
              ),
            ),
            // Tappable areas.
            ..._footAreas.map((area) {
              // Scale each area’s coordinates.
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
                      // Use red overlay for selected; otherwise transparent.
                      color: _selectedAreas.contains(area.id)
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.transparent,
                      // The grid option is available in the UI but not used here.
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
