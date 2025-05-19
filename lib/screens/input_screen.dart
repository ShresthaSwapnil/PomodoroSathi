// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/screens/timer_screen.dart';
import 'package:pomo_app/services/user_prefs_service.dart';
import 'package:pomo_app/utils/colors.dart';
import 'package:pomo_app/utils/animations.dart'; 
import 'package:animations/animations.dart';


class InputScreen extends StatefulWidget {
  final String? initialName;
  final SessionModel? previousSession; 

  const InputScreen({super.key, this.initialName, this.previousSession});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late TextEditingController _titleController;
  int _selectedWorkDuration = 15;
  int _selectedBreakDuration = 5;
  int _selectedPriority = 1; 
  String _userName = "User";
  final UserPrefsService _prefsService = UserPrefsService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _titleController = TextEditingController(text: widget.previousSession?.title ?? "");
    _selectedWorkDuration = widget.previousSession?.workDurationMinutes ?? 15;
    _selectedBreakDuration = widget.previousSession?.breakDurationMinutes ?? 5;
    _selectedPriority = widget.previousSession?.priority ?? 1;
  }

  Future<void> _loadUserName() async {
    final name = await _prefsService.getUserName();
    if (mounted && name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  void _startSession() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a title for your session!')),
      );
      return;
    }

    final session = SessionModel(
      userName: _userName,
      title: _titleController.text,
      workDurationMinutes: _selectedWorkDuration,
      breakDurationMinutes: _selectedBreakDuration,
      priority: _selectedPriority,
      completionDate: DateTime.now(), 
    );

    Navigator.of(context).push(
      // Using the slideUpTransition from utils/animations.dart
      AppScreenTransitions.sharedAxis(TimerScreen(session: session), SharedAxisTransitionType.vertical),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'pomodoro.',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              // Pass the full name to ui-avatars.com. It's good at creating initials.
              // Use a fallback if the name is empty.
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=${_userName.trim().isNotEmpty ? Uri.encodeComponent(_userName.trim()) : "P"}&background=random&color=fff&size=128'
              ),
              radius: 18,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_userName!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textColor.withOpacity(0.8)),
            ),
            SizedBox(height: 5),
            Text(
              'Create a new Session',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28),
            ),
            SizedBox(height: 25),
            _buildSessionCard(context),
            SizedBox(height: 30),
            _buildPrioritySelectorSection(),
            SizedBox(height: 20),
             Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.play_arrow, color: Colors.white),
                label: Text('START SESSION', style: TextStyle(color: Colors.white)),
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    return Container(
        width: double.infinity, 
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Title Input ---
            TextField(
              controller: _titleController,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Session Title',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 8),
            Text(
              // Example: Displaying current priority in the card if desired
              'Priority: $_selectedPriority',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 25),
            // --- Work Duration Selection ---
            Text('WORK DURATION', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDurationChip(5, _selectedWorkDuration, (val) => setState(() => _selectedWorkDuration = val), "WORK"),
                _buildDurationChip(15, _selectedWorkDuration, (val) => setState(() => _selectedWorkDuration = val), "WORK"),
                _buildDurationChip(25, _selectedWorkDuration, (val) => setState(() => _selectedWorkDuration = val), "WORK"),
              ],
            ),
            SizedBox(height: 20),
            // --- Break Duration Selection ---
            Text('BREAK DURATION', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDurationChip(2, _selectedBreakDuration, (val) => setState(() => _selectedBreakDuration = val), "BREAK"),
                _buildDurationChip(5, _selectedBreakDuration, (val) => setState(() => _selectedBreakDuration = val), "BREAK"),
                _buildDurationChip(10, _selectedBreakDuration, (val) => setState(() => _selectedBreakDuration = val), "BREAK"),

              ],
            ),
          ],
        ),
      );
  }

  Widget _buildDurationChip(int duration, int selectedDuration, ValueChanged<int> onSelected, String type) {
    final bool isSelected = duration == selectedDuration;
    return ChoiceChip(
      label: Text(
        '$duration min',
        style: TextStyle(color: isSelected ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          onSelected(duration);
        }
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      selectedColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

   Widget _buildPrioritySelectorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Session Priority (Optional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textColor.withOpacity(0.7)),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Better spacing for 3 items
          children: [
            _buildPriorityCircle("1", 1, isSelected: _selectedPriority == 1),
            _buildPriorityCircle("2", 2, isSelected: _selectedPriority == 2),
            _buildPriorityCircle("3", 3, isSelected: _selectedPriority == 3),
            // "Add" button removed as per your feedback
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityCircle(String number, int priorityValue, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priorityValue;
        });
      },
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.secondary.withOpacity(0.1),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2.5) : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          number,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}