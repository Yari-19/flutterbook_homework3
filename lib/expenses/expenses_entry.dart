import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expenses_model.dart';

/// Form used to create or edit an expense.
///
/// Validates the title and amount before saving through [ExpensesModel].
/// Cancel returns to the list without persisting the form values.
class ExpensesEntry extends StatefulWidget {
  /// Creates the form; requires an ancestor provider of [ExpensesModel].
  const ExpensesEntry({super.key});

  @override
  State<ExpensesEntry> createState() => _ExpensesEntryState();
}

class _ExpensesEntryState extends State<ExpensesEntry> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Expense? _currentExpense;

  String _category = 'Other';
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();

  static const List<String> _categories = [
    'Food',
    'Shopping',
    'Transportation',
    'Bills',
    'Entertainment',
    'Other',
  ];

  static const List<String> _paymentMethods = [
    'Cash',
    'Debit Card',
    'Credit Card',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Loads [expense] into the controllers when a different entry is selected.
  void _loadExpense(Expense expense) {
    _currentExpense = expense;

    _titleController.text = expense.title;

    _amountController.text = expense.amount == 0
        ? ''
        : expense.amount.toString();

    _descriptionController.text = expense.description ?? '';

    _category = expense.category;
    _paymentMethod = expense.paymentMethod;
    _selectedDate = expense.expenseDate ?? DateTime.now();
  }

  /// Opens a calendar to select the expense date.
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Validates the title and positive finite amount, then persists the expense.
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final model = context.read<ExpensesModel>();
    final expense = model.entryBeingEdited;

    if (expense == null) return;

    expense.title = _titleController.text.trim();
    expense.amount = double.parse(_amountController.text.trim());
    expense.description = _descriptionController.text.trim();
    expense.category = _category;
    expense.paymentMethod = _paymentMethod;
    expense.expenseDate = _selectedDate;

    await model.stopEditingEntry(save: true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Discards unsaved form values and reloads persisted entries.
  Future<void> _cancelEditing() async {
    final model = context.read<ExpensesModel>();
    await model.stopEditingEntry();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpensesModel>();
    final expense = model.entryBeingEdited;

    // Only populate the form when switching expenses.
    if (expense != null && !identical(_currentExpense, expense)) {
      _loadExpense(expense);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(expense?.isNew ?? true ? 'Add Expense' : 'Edit Expense'),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');

                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter a valid amount greater than 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Expense Date'),
              subtitle: Text(
                '${_selectedDate.month}/'
                '${_selectedDate.day}/'
                '${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _selectDate,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TextButton(onPressed: _cancelEditing, child: const Text('Cancel')),
            const Spacer(),
            FilledButton(onPressed: _saveExpense, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
