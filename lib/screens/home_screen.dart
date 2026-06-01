import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/expense_model.dart';
import '../widget/buttomshit.dart';

class ExpenseTrackerHome extends StatefulWidget {
  const ExpenseTrackerHome({super.key});

  @override
  State<ExpenseTrackerHome> createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('user_expenses');
    if (cachedData != null) {
      final List<dynamic> decodedList = jsonDecode(cachedData);
      setState(() {
        _expenses = decodedList.map((item) => Expense.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_expenses.map((e) => e.toMap()).toList());
    await prefs.setString('user_expenses', encodedData);
  }

  void _openExpenseFormModal({Expense? existingExpense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ExpenseFormBottomSheet(
          existingExpense: existingExpense,
          onSave: (title, amount, category, date, description) {
            setState(() {
              if (existingExpense == null) {

                _expenses.add(Expense(
                  id: DateTime.now().toString(),
                  title: title,
                  amount: amount,
                  category: category,
                  date: date,
                  description: description,
                ));
              } else {

                final index = _expenses.indexWhere((element) => element.id == existingExpense.id);
                _expenses[index] = Expense(
                  id: existingExpense.id,
                  title: title,
                  amount: amount,
                  category: category,
                  date: date,
                  description: description,
                );
              }
            });
            _saveExpenses();
          },
        );
      },
    );
  }

  void _deleteExpense(String id) {
    setState(() {
      _expenses.removeWhere((element) => element.id == id);
    });
    _saveExpenses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = _expenses.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text('Total Expenses This Month', style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 5),
                Text(
                  '\$${totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          // Expense List
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses added yet!',style:
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500
            ),))
                : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (ctx, index) {
                final expense = _expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: FittedBox(child: Text('\$${expense.amount.toStringAsFixed(0)}')),
                      ),
                    ),
                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${expense.category} | ${DateFormat.yMMMd().format(expense.date)}\n${expense.description}'),
                    isThreeLine: expense.description.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openExpenseFormModal(existingExpense: expense),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteExpense(expense.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openExpenseFormModal(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
