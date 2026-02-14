import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  bool _isCountdownActive = false;
  bool _isPressing = false;
  int _countdown = 5;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _isPressing = false;
      _countdown = 5;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _isCountdownActive = false);
        if (mounted) _sendWhatsAppSOS();
      }
    });
  }

  Future<void> _sendWhatsAppSOS() async {
    final userState = Provider.of<UserState>(context, listen: false);
    final contacts = userState.emergencyContacts;
    
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contacts saved! Add contacts first.')),
      );
      return;
    }

    // Get location
    String locationLink = "Unknown Location";
    if (userState.currentCoordinates != "Unknown") {
      final coords = userState.currentCoordinates.replaceAll(" ", ""); // Remove spaces
      locationLink = "https://www.google.com/maps/search/?api=1&query=$coords";
    }

    // Message Content
    final message = Uri.encodeComponent(
      "🆘 SOS! I need help immediately. My current location is: $locationLink"
    );

    int sentCount = 0;
    // Iterate through contacts and send WhatsApp message
    for (var contact in contacts) {
      // Basic sanitization: keep only digits
      final phone = contact.phone.replaceAll(RegExp(r'\D'), '');
      
      if (phone.isNotEmpty) {
        // Construct the WhatsApp URL
        final whatsappUrl = Uri.parse("https://wa.me/$phone?text=$message");
        
        try {
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
            sentCount++;
            // Small delay to allow app switch (especially on mobile)
            await Future.delayed(const Duration(seconds: 2)); 
          } else {
             debugPrint('Could not launch WhatsApp for ${contact.name}');
          }
        } catch (e) {
          debugPrint('Error launching WhatsApp: $e');
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOS Alert triggered for $sentCount contacts via WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addContactDialog(BuildContext context, UserState state) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                state.addContact(nameController.text, phoneController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Travel Mode Variables
  bool _isTravelModeActive = false;
  Timer? _checkInTimer;
  Timer? _alertTimer;
  int _checkInIntervalMinutes = 15;
  int _alertCountdown = 60;
  bool _isAlertActive = false;

  @override
  void dispose() {
    _timer?.cancel();
    _checkInTimer?.cancel();
    _alertTimer?.cancel();
    super.dispose();
  }

  void _startTravelMode() {
    setState(() {
      _isTravelModeActive = true;
    });
    _scheduleNextCheckIn();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Travel Mode Started. Checking in every $_checkInIntervalMinutes mins.')),
    );
  }

  void _stopTravelMode() {
    _checkInTimer?.cancel();
    _alertTimer?.cancel();
    setState(() {
      _isTravelModeActive = false;
      _alertCountdown = 60;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Travel Mode Stopped.')),
    );
  }

  void _scheduleNextCheckIn() {
    _checkInTimer?.cancel();
    _checkInTimer = Timer(Duration(minutes: _checkInIntervalMinutes), () {
       if (mounted) _showSafetyCheckDialog();
    });
  }

  void _showSafetyCheckDialog() {
    _alertCountdown = 60;
    
    // Start countdown for auto-alert
    _alertTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
         _alertCountdown--;
      });

      if (_alertCountdown <= 0) {
        timer.cancel();
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
        _sendWhatsAppSOS(); // Auto trigger SOS
        _stopTravelMode(); // Stop mode after triggering
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Safety Check"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you safe? Please confirm."),
            const SizedBox(height: 20),
            Text(
              "Auto-alert in $_alertCountdown s",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
             onPressed: () {
               _alertTimer?.cancel();
               Navigator.of(context, rootNavigator: true).pop();
               _sendWhatsAppSOS();
               _stopTravelMode();
             },
             child: const Text("NOT SAFE (SOS)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _alertTimer?.cancel();
              Navigator.of(context, rootNavigator: true).pop();
              _scheduleNextCheckIn();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safety Confirmed. Next check scheduled.')),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text("I'M SAFE"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModeCard() {
    return Card(
      color: _isTravelModeActive ? Colors.green.shade50 : Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_isTravelModeActive ? Icons.directions_car : Icons.time_to_leave, 
                  color: _isTravelModeActive ? Colors.green : Colors.blue, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTravelModeActive ? "Travel Mode Active" : "Travel Mode",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: _isTravelModeActive ? Colors.green.shade800 : Colors.blue.shade800
                        ),
                      ),
                      Text(
                        _isTravelModeActive 
                          ? "Checking safety every $_checkInIntervalMinutes mins"
                          : "Auto-alerts if you don't check in",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isTravelModeActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Check-in Interval:"),
                  DropdownButton<int>(
                    value: _checkInIntervalMinutes,
                    items: [1, 5, 10, 15, 30, 60].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value mins'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _checkInIntervalMinutes = val);
                    },
                  ),
                ],
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTravelModeActive ? _stopTravelMode : _startTravelMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTravelModeActive ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(_isTravelModeActive ? "STOP TRAVEL MODE" : "START TRAVEL MODE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Safety')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTravelModeCard(),
                const SizedBox(height: 24),
                _buildSectionHeader('Current Location', Icons.my_location),
                Card(
                  child: ListTile(
                    title: Text(userState.isSharingLocation ? 'Sharing Active' : 'Sharing Paused'),
                    subtitle: Text('Coordinates: ${userState.currentCoordinates}'),
                    trailing: Switch(
                      value: userState.isSharingLocation,
                      onChanged: (val) => userState.toggleLocation(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Emergency Contacts', Icons.people),
                ...userState.emergencyContacts.map((contact) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(contact.name),
                    subtitle: Text(contact.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => launchUrl(Uri.parse('tel:${contact.phone}')),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => userState.removeContact(contact.id),
                        ),
                      ],
                    ),
                  ),
                )),
                TextButton.icon(
                  onPressed: () => _addContactDialog(context, userState),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Contact'),
                ),
                const SizedBox(height: 100), // Space for SOS button
              ],
            ),
          ),
          // Floating SOS Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hold for 2s for SOS', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onLongPressStart: (_) => setState(() => _isPressing = true),
                    onLongPressEnd: (_) => setState(() => _isPressing = false),
                    onLongPress: _startCountdown,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isPressing ? 140 : 120,
                      height: _isPressing ? 140 : 120,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(_isPressing ? 0.6 : 0.4), blurRadius: 20, spreadRadius: 10),
                        ],
                      ),
                      child: const Center(child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isCountdownActive)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sending SOS in...', style: TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 20),
                    Text('$_countdown', style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() => _isCountdownActive = false);
                      },
                      child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
