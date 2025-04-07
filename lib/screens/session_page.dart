import 'package:flutter/material.dart';
import 'dart:async';
// Import the NeuromodulationCalculator
import '../services/neuromodulation_calculator.dart';
import '../services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const SessionScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool timerEnabled = true;
  double sessionDuration = 8.0; // Default 8 minutes
  String selectedLocation = "Right foot"; // Default selected location
  int intensityLevel = 2; // Default to show 3 colored bars (indices 0, 1, 2)

  // Added variables for running state
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? sessionTimer;
  Timer? stimulationTimer;

  // Paradigm selection variables
  String selectedParadigm = "Standard";
  bool setParadigmAsDefault = false;

  // Neuromodulation variables
  Map<String, dynamic>? modulationResults;
  double currentPressure = 0.0;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get the current user directly from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          currentUsername = user.email;
        });
      } else {}
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    stimulationTimer?.cancel();
    super.dispose();
  }

  // Update stimulation based on the current pressure and paradigm
  Future<void> updateStimulation(double pressure) async {
    if (currentUsername == null) return;

    try {
      // Convert foot location to a zone for the calculator
      String footZone = _getFootZoneFromLocation();

      // Calculate the modulation based on selected paradigm
      if (selectedParadigm == "Standard") {
        // Simple linear amplitude modulation based on intensity level
        double normalizedIntensity =
            intensityLevel / 4.0; // Convert 0-4 to 0.0-1.0
        currentPressure = normalizedIntensity * pressure;
        // Use linear amplitude for standard paradigm
        double amplitude =
            NeuromodulationCalculator.linearAmplitude(currentPressure);
        setState(() {
          modulationResults = {
            'amplitude': {'standard': amplitude},
            'electrode': footZone,
            'pressure': currentPressure
          };
          print(modulationResults);
        });
      } else {
        // For Advanced or Hybrid paradigms, use the full calculator
        double adjustedPressure = (intensityLevel / 4.0) * pressure;
        currentPressure = adjustedPressure;

        // Use database service directly to get electrode mapping
        DatabaseService db = DatabaseService();
        String? electrodeMapping =
            await db.getElectrodeMappingByUsername(currentUsername!);

        if (electrodeMapping != null) {
          // Use frequency modulation from the calculator
          Map<String, double> frequency =
              NeuromodulationCalculator.frequencyModulation(
                  electrodeMapping, adjustedPressure);

          // Use proper amplitude calculation based on paradigm
          Map<String, double> amplitudes = {};
          frequency.forEach((key, value) {
            if (selectedParadigm == "Hybrid") {
              amplitudes[key] = NeuromodulationCalculator.hybridAmplitude(
                  adjustedPressure, value);
            } else {
              // Advanced paradigm uses linear amplitude
              amplitudes[key] =
                  NeuromodulationCalculator.linearAmplitude(adjustedPressure);
            }
          });

          setState(() {
            modulationResults = {
              'electrode': electrodeMapping,
              'frequency': frequency,
              'amplitude': amplitudes
            };
          });
        } else {
          print('Electrode mapping not found for user: $currentUsername');
          // Fallback to basic calculation
          setState(() {
            modulationResults = {
              'amplitude': {
                'standard':
                    NeuromodulationCalculator.linearAmplitude(adjustedPressure)
              },
              'electrode': footZone,
              'pressure': adjustedPressure
            };
          });
        }
      }
    } catch (e) {
      print('Error updating stimulation: $e');
    }
  }

  // Convert UI location to footZone for the calculator
  String _getFootZoneFromLocation() {
    // This is a simplified mapping, adjust as needed based on your actual zones
    if (selectedLocation == "Right foot" || selectedLocation == "Left foot") {
      // Default to midfoot, but ideally this would be more specific
      return "midfoot";
    }
    return "midfoot"; // Default fallback
  }

  void startSession() {
    setState(() {
      isRunning = true;
      // If timer is disabled, use 15 minutes, otherwise use the slider value
      remainingSeconds = timerEnabled
          ? sessionDuration.toInt() * 60
          : 0; // 15 minutes in seconds
    });

    // Start the session timer
    sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerEnabled) {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            // Auto-stop when countdown reaches zero
            stopSession();
          }
        } else {
          remainingSeconds++;
        }
      });
    });

    // Start the stimulation timer that simulates pressure changes and updates modulation
    stimulationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      // Simulate pressure changes during the session
      double sessionProgress = timerEnabled
          ? 1.0 - (remainingSeconds / (sessionDuration.toInt() * 60))
          : 0.5; // Default pressure for unlimited sessions

      // Use the pressure profile simulation from NeuromodulationCalculator
      double simulatedPressure =
          NeuromodulationCalculator.simulatePressureProfile(
              sessionProgress, 0.0, 0.2, 0.8, 1.0);

      // Update stimulation based on the current paradigm and pressure
      updateStimulation(simulatedPressure);
    });
  }

  void stopSession() {
    setState(() {
      isRunning = false;
      sessionTimer?.cancel();
      sessionTimer = null;
      stimulationTimer?.cancel();
      stimulationTimer = null;
      modulationResults = null;
      currentPressure = 0.0;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Show paradigm selection dialog
  void _showParadigmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Local variables for the dialog state
        String tempSelectedParadigm = selectedParadigm;
        bool tempSetAsDefault = setParadigmAsDefault;

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  Text("Paradigm of stimulation",
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 16),

                  // Standard option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Standard";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Standard"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Standard"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Standard")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Standard",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Standard"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Advanced option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Advanced";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Advanced"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Advanced"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Advanced")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Advanced",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Advanced"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Hybrid option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Hybrid";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Hybrid"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Hybrid"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Hybrid")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Hybrid",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Hybrid"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Set as default toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSetAsDefault = !tempSetAsDefault;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            color: tempSetAsDefault
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: tempSetAsDefault ? 2 : null,
                                left: tempSetAsDefault ? null : 2,
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
                      SizedBox(width: 10),
                      Text(
                        "Set up as a default setting",
                        style: TextStyle(
                          color: const Color(0xFF3A6470),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      // Update the main state with selected values
                      this.setState(() {
                        selectedParadigm = tempSelectedParadigm;
                        setParadigmAsDefault = tempSetAsDefault;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A6470),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                                          ? const Color(0xFF3A6470)
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
                            color: const Color(0xFF3A6470),
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

                    SizedBox(height: 20),

                    // Session duration and elapsed time toggle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set session duration",
                        style: TextStyle(
                          color: Color(0xFF3A6470),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

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
                            color: isRunning ? Colors.green : Color(0xFF3A6470),
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
                              : const Color(0xFF3A6470),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: isRunning
                              ? Colors.grey[400]
                              : const Color(0xFF3A6470),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("3",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("5",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("7",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("9",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("12",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
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

              // Stimulation info display
              if (isRunning && modulationResults != null)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
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
                      Text(
                        "Neuromodulation Info",
                        style: TextStyle(
                          color: const Color(0xFF3A6470),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Paradigm: $selectedParadigm",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Location: $selectedLocation",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Pressure: ${(currentPressure * 100).toStringAsFixed(1)}%",
                        style: TextStyle(fontSize: 14),
                      ),
                      if (modulationResults!.containsKey('frequency'))
                        Text(
                          "Frequencies: ${_formatFrequencies(modulationResults!['frequency'])}",
                          style: TextStyle(fontSize: 14),
                        ),
                      if (modulationResults!.containsKey('amplitude'))
                        Text(
                          "Amplitudes: ${_formatAmplitudes(modulationResults!['amplitude'])}",
                          style: TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),

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
                        size: 24,
                        color: Colors.white),
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
                          child: Icon(Icons.add,
                              color: Colors.grey[700], size: 28),
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
                          selectedLocation = "Left foot";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedLocation == "Left foot"
                            ? const Color(0xFF3A6470)
                            : Colors.white,
                        foregroundColor: selectedLocation == "Left foot"
                            ? Colors.white
                            : Colors.grey[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: selectedLocation == "Left foot"
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedLocation == "Left foot")
                            Icon(Icons.check, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Left foot"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedLocation = "Right foot";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedLocation == "Right foot"
                            ? const Color(0xFF3A6470)
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
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedLocation == "Right foot")
                            Icon(Icons.check, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Right foot"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isRunning ? widget.onContinue : null,
                        child: Text("Change location"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isRunning ? _showParadigmDialog : null,
                        child: Text("Change paradigm"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to format frequency data
  String _formatFrequencies(Map<String, dynamic> frequencies) {
    StringBuffer buffer = StringBuffer();
    frequencies.forEach((key, value) {
      buffer.write('$key: ${value.toStringAsFixed(1)}Hz, ');
    });
    String result = buffer.toString();
    if (result.isNotEmpty) {
      result = result.substring(
          0, result.length - 2); // Remove trailing comma and space
    }
    return result;
  }

  // Helper function to format amplitude data
  String _formatAmplitudes(Map<String, dynamic> amplitudes) {
    StringBuffer buffer = StringBuffer();
    amplitudes.forEach((key, value) {
      buffer.write('$key: ${value.toStringAsFixed(2)}, ');
    });
    String result = buffer.toString();
    if (result.isNotEmpty) {
      result = result.substring(
          0, result.length - 2); // Remove trailing comma and space
    }
    return result;
  }
}
