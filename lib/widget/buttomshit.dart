import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/expense_model.dart';

class ExpenseFormBottomSheet extends StatefulWidget {
  final Expense? existingExpense;
  final Function(String title, double amount, String category, DateTime date, String description) onSave;

  const ExpenseFormBottomSheet({
    super.key,
    this.existingExpense,
    required this.onSave,
  });

  @override
  State<ExpenseFormBottomSheet> createState() => _ExpenseFormBottomSheetState();
}

class _ExpenseFormBottomSheetState extends State<ExpenseFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Entertainment', 'Shopping', 'Others'];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.existingExpense?.title ?? '');
    _amountController = TextEditingController(text: widget.existingExpense?.amount.toString() ?? '');
    _descController = TextEditingController(text: widget.existingExpense?.description ?? '');
    _selectedCategory = widget.existingExpense?.category ?? 'Food';
    _selectedDate = widget.existingExpense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existingExpense == null ? 'Add New Expense' : 'Edit Expense',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Expense Title'),
                validator: (val) => val!.trim().isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Amount cannot be empty';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      _titleController.text.trim(),
                      double.parse(_amountController.text.trim()),
                      _selectedCategory,
                      _selectedDate,
                      _descController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(widget.existingExpense == null ? 'Add Expense' : 'Update Expense'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}