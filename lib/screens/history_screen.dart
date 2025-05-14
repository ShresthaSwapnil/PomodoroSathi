// lib/screens/history_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/services/history_service.dart';
import 'package:pomo_app/utils/colors.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<SessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await _historyService.getSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear History?'),
          content: Text('Are you sure you want to delete all session history? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Clear', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _historyService.clearHistory();
      _loadHistory(); // Refresh the list
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session History', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: AppColors.secondary.withOpacity(0.7)),
              onPressed: _clearHistory,
              tooltip: 'Clear All History',
            )
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey.shade400),
                      SizedBox(height: 20),
                      Text(
                        'No sessions recorded yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Complete a Pomodoro session to see it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                onRefresh: _loadHistory,
                color: AppColors.primary,
                child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return Card(
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: Text(
                              session.priority.toString(),
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            session.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textColor),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                'User: ${session.userName}',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Work: ${session.workDurationMinutes} min, Break: ${session.breakDurationMinutes} min',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 3),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(session.completionDate),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.check_circle_outline, color: AppColors.primary.withOpacity(0.7)),
                        ),
                      );
                    },
                  ),
              ),
    );
  }
}