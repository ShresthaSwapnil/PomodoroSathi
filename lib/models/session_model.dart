// import 'package:flutter/foundation.dart'; // For @required

class SessionModel {
  String title;
  int workDurationMinutes;
  int breakDurationMinutes;
  String userName;
  int priority;
  DateTime completionDate; // New field
  String? id; // Optional: Unique ID for session, useful for DBs

  SessionModel({
    required this.title,
    required this.workDurationMinutes,
    required this.breakDurationMinutes,
    required this.userName,
    required this.priority,
    required this.completionDate,
    this.id,
  });

  // Factory constructor to create a SessionModel from JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      workDurationMinutes: json['workDurationMinutes'] as int,
      breakDurationMinutes: json['breakDurationMinutes'] as int,
      userName: json['userName'] as String,
      priority: json['priority'] as int,
      completionDate: DateTime.parse(json['completionDate'] as String),
    );
  }

  // Method to convert a SessionModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? DateTime.now().toIso8601String(), // Generate ID if null
      'title': title,
      'workDurationMinutes': workDurationMinutes,
      'breakDurationMinutes': breakDurationMinutes,
      'userName': userName,
      'priority': priority,
      'completionDate': completionDate.toIso8601String(),
    };
  }
}