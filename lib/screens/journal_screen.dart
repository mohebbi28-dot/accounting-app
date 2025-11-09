import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = '1403/01/01';
    _endDateController.text = '1403/12/29';
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _dbHelper.getJournalEntries();
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      // داده‌های نمونه
      setState(() {
        _transactions = [
          {
            'id': 1,
            'transaction_date': '1403/10/15',
            'from_account': 'نقد',
            'to_account': 'خوراک',
            'amount': 50000.0,
            'description': 'خرید ناهار'
          },
          {
            'id': 2,
            'transaction_date': '1403/10/14',
            'from_account': 'بانک',
            'to_account': 'اجاره',
            'amount': 2000000.0,
            'description': 'پرداخت اجاره'
          }
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر روزنامه'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // فیلترها
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startDateController,
                            decoration: const InputDecoration(
                              labelText: 'تاریخ شروع',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endDateController,
                            decoration: const InputDecoration(
                              labelText: 'تاریخ پایان',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loadTransactions,
                            child: const Text('اعمال فیلتر'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            child: const Text('پاک کردن فیلتر'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // لیست تراکنش‌ها
            Expanded(
              child: _transactions.isEmpty
                  ? const Center(
                      child: Text('تراکنشی یافت نشد'),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.receipt, color: Colors.teal),
                            title: Text(
                              '${transaction['from_account']} → ${transaction['to_account']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'تاریخ: ${transaction['transaction_date']}'),
                                Text(
                                    'مبلغ: ${_formatNumber(transaction['amount'])}'),
                                if (transaction['description'] != null)
                                  Text(
                                      'توضیحات: ${transaction['description']}'),
                              ],
                            ),
                            trailing: Text(
                              _formatNumber(transaction['amount']),
                              style: TextStyle(
                                color: transaction['amount'] > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic number) {
    final numValue = number is int ? number : (number as num).toInt();
    return numValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _clearFilters() {
    _startDateController.text = '1403/01/01';
    _endDateController.text = '1403/12/29';
    _loadTransactions();
  }
}
