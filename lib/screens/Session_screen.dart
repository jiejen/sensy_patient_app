import 'package:flutter/material.dart';
import 'dart:async';

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool timerEnabled = true;
  bool elapsedTimeEnabled = false;
  double sessionDuration = 8.0; // Default 8 minutes
  String selectedLocation = "Right foot"; // Default selected location
  int intensityLevel = 2; // Default to show 3 colored bars (indices 0, 1, 2)

  // Added variables for running state
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? sessionTimer;

  @override
  void dispose() {
    sessionTimer?.cancel();
    super.dispose();
  }

  void startSession() {
    setState(() {
      isRunning = true;
      // If timer is disabled, use 15 minutes, otherwise use the slider value
      remainingSeconds = timerEnabled
          ? sessionDuration.toInt() * 60
          : 15 * 60; // 15 minutes in seconds
    });

    // Start the timer
    sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // Auto-stop when countdown reaches zero
          stopSession();
        }
      });
    });
  }

  void stopSession() {
    setState(() {
      isRunning = false;
      sessionTimer?.cancel();
      sessionTimer = null;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF5E8D9B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              "SENSARS",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.info_outline,
              color: const Color(0xFF5E8D9B),
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              "Connection status",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
        child: Column(
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
                      padding: EdgeInsets.symmetric(vertical: 12),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Walking mode",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Timer settings container
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer switch
                  Row(
                    children: [
                      GestureDetector(
                        onTap: !isRunning
                            ? () {
                                setState(() {
                                  timerEnabled = !timerEnabled;
                                });
                              }
                            : null,
                        child: Container(
                          width: 50,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFACC7CF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: timerEnabled ? 3 : null,
                                left: timerEnabled ? null : 3,
                                top: 3,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: timerEnabled
                                        ? const Color(0xFF5E8D9B)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Timer",
                        style: TextStyle(
                          color: const Color(0xFF5E8D9B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Text(
                        isRunning ? "• Running" : "• Not running",
                        style: TextStyle(
                          color: isRunning ? Colors.green : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Session duration and elapsed time toggle
                  Row(
                    children: [
                      Text(
                        "Set session duration",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: !isRunning
                            ? () {
                                setState(() {
                                  elapsedTimeEnabled = !elapsedTimeEnabled;
                                });
                              }
                            : null,
                        child: Container(
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            color: elapsedTimeEnabled
                                ? const Color(0xFF5E8D9B)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: elapsedTimeEnabled ? 2 : null,
                                left: elapsedTimeEnabled ? null : 2,
                                top: 2,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Elapsed time",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Session duration value or timer display
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    color: isRunning
                        ? const Color(
                            0xFFE8F5E9) // Light green background when running
                        : const Color(0xFFF0F3F5),
                    child: Center(
                      child: Text(
                        isRunning
                            ? formatTime(remainingSeconds)
                            : timerEnabled
                                ? "${sessionDuration.toInt()} min"
                                : "0 min",
                        style: TextStyle(
                          color: isRunning
                              ? Colors.green
                              : const Color(0xFF5E8D9B),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Session duration slider (only visible when timer is enabled)
                  if (timerEnabled)
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: isRunning
                            ? Colors.grey[400]
                            : const Color(0xFF5E8D9B),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: isRunning
                            ? Colors.grey[400]
                            : const Color(0xFF5E8D9B),
                      ),
                      child: Column(
                        children: [
                          Slider(
                            value: sessionDuration,
                            min: 1,
                            max: 12,
                            divisions: 11,
                            onChanged: isRunning
                                ? null
                                : (value) {
                                    setState(() {
                                      sessionDuration = value;
                                    });
                                  },
                          ),
                          // Slider labels
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("1",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text("3",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text("5",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text("7",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text("9",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text("12",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Start/Stop button
            ElevatedButton(
              onPressed: () {
                // Toggle between Start and Stop
                if (isRunning) {
                  stopSession();
                } else {
                  startSession();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRunning ? Colors.red : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      isRunning
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: 24),
                  SizedBox(width: 8),
                  Text(
                    isRunning ? "Stop" : "Start",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Intensity bars
            Container(
              height: 240,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Minus button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (intensityLevel > 0) intensityLevel--;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(Icons.remove,
                            color: Colors.grey[700], size: 28),
                      ),
                    ),
                  ),

                  // Intensity bars
                  ...List.generate(5, (index) {
                    return Container(
                      width: 50,
                      height: 80.0 + (index * 30.0),
                      decoration: BoxDecoration(
                        color: index <= intensityLevel
                            ? const Color(0xFF5E8D9B)
                            : const Color(0xFFB8C9CE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),

                  // Plus button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (intensityLevel < 4) intensityLevel++;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child:
                            Icon(Icons.add, color: Colors.grey[700], size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Location selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedLocation = "Right foot";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedLocation == "Right foot"
                          ? const Color(0xFF5E8D9B)
                          : Colors.white,
                      foregroundColor: selectedLocation == "Right foot"
                          ? Colors.white
                          : Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: selectedLocation == "Right foot"
                              ? const Color(0xFF5E8D9B)
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedLocation == "Right foot")
                          Icon(Icons.check, size: 16),
                        SizedBox(width: 6),
                        Text("Right foot"),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedLocation = "Right calf";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedLocation == "Right calf"
                          ? const Color(0xFF5E8D9B)
                          : Colors.white,
                      foregroundColor: selectedLocation == "Right calf"
                          ? Colors.white
                          : Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: selectedLocation == "Right calf"
                              ? const Color(0xFF5E8D9B)
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedLocation == "Right calf")
                          Icon(Icons.check, size: 16),
                        SizedBox(width: 6),
                        Text("Right calf"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Spacer(),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle change location
                        Navigator.of(context)
                            .pop(); // Return to previous screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E8D9B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text("Change location"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle change paradigm
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E8D9B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text("Change paradigm"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
