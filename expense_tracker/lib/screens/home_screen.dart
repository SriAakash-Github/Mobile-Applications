import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database/db_helper.dart';
import '../widgets/expense_item.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  _refreshExpenses() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    
    setState(() {
      _expenses = expenses;
      _totalExpenses = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildExpenseList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewExpense,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Total Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_totalExpenses.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_expenses.length} expenses recorded',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No expenses recorded yet.\nTap + to add your first expense.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          return ExpenseItem(
            expense: _expenses[index],
            onDelete: () => _deleteExpense(_expenses[index].id!),
          );
        },
      ),
    );
  }

  _addNewExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (result != null && result) {
      _refreshExpenses();
    }
  }

  _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _refreshExpenses();
  }
}