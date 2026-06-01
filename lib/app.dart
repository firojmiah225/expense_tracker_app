import 'package:expense_tracker_app/screens/home_screen.dart';
import 'package:flutter/material.dart';


class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home:  ExpenseTrackerHome(),
    );
  }
}
