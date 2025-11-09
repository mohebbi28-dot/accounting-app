import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _ledgerEntries = [];

  String? _selectedAccount;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = '1403/01/01';
    _endDateController.text = '1403/12/29';
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _dbHelper.getAllAccountsWithDetails();
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      // داده‌های نمونه
      setState(() {
        _accounts = [
          {
            'account_name': 'نقد',
            'account_type': 'بانک',
            'initial_balance': 1000000
          },
          {
            'account_name': 'بانک',
            'account_type': 'بانک',
            'initial_balance': 5000000
          },
          {
            'account_name': 'خوراک',
            'account_type': 'هزینه',
            'initial_balance': 0
          },
          {
            'account_name': 'اجاره',
            'account_type': 'هزینه',
            'initial_balance': 0
          },
        ];
      });
    }
  }

  Future<void> _loadLedgerEntries() async {
    try {
      final entries = await _dbHelper.getLedgerEntries(
        accountName: _selectedAccount,
        startDate: _startDateController.text.isEmpty
            ? null
            : _startDateController.text,
        endDate:
            _endDateController.text.isEmpty ? null : _endDateController.text,
      );
      setState(() {
        _ledgerEntries = entries;
      });
    } catch (e) {
      // داده‌های نمونه
      setState(() {
        _ledgerEntries = [
          {
            'account_name': 'نقد',
            'transaction_date': '1403/10/15',
            'from_account': 'نقد',
            'to_account': 'خوراک',
            'amount': -50000.0,
            'balance': 950000.0,
            'description': 'خرید ناهار'
          },
          {
            'account_name': 'خوراک',
            'transaction_date': '1403/10/15',
            'from_account': 'نقد',
            'to_account': 'خوراک',
            'amount': 50000.0,
            'balance': 50000.0,
            'description': 'خرید ناهار'
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر کل'),
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
                    // انتخاب حساب
                    DropdownButtonFormField<String>(
                      value: _selectedAccount,
                      decoration: const InputDecoration(
                        labelText: 'انتخاب حساب (اختیاری)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('همه حساب‌ها'),
                        ),
                        ..._accounts.map((account) {
                          return DropdownMenuItem<String>(
                            value: account['account_name'],
                            child: Text(account['account_name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAccount = newValue;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // فیلتر تاریخ
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

                    // دکمه‌های فیلتر
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loadLedgerEntries,
                            child: const Text('نمایش گردش'),
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

            // اطلاعات حساب انتخاب شده
            if (_selectedAccount != null)
              FutureBuilder<double>(
                future: _dbHelper.getAccountBalance(_selectedAccount!),
                builder: (context, snapshot) {
                  final balance = snapshot.data ?? 0;
                  return Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حساب: $_selectedAccount',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'موجودی فعلی: ${_formatNumber(balance)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: balance >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // لیست گردش‌ها
            Expanded(
              child: _ledgerEntries.isEmpty
                  ? const Center(
                      child: Text('گردشی یافت نشد'),
                    )
                  : ListView.builder(
                      itemCount: _ledgerEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _ledgerEntries[index];
                        final isDebit = entry['amount'] < 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isDebit
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isDebit ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              _selectedAccount != null
                                  ? '${entry['from_account']} → ${entry['to_account']}'
                                  : entry['account_name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('تاریخ: ${entry['transaction_date']}'),
                                Text(
                                    '${isDebit ? 'بدهکار' : 'بستانکار'}: ${_formatNumber(entry['amount'].abs())}'),
                                if (entry['description'] != null)
                                  Text('توضیحات: ${entry['description']}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatNumber(entry['amount']),
                                  style: TextStyle(
                                    color: isDebit ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'مانده: ${_formatNumber(entry['balance'])}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
    setState(() {
      _selectedAccount = null;
      _startDateController.text = '1403/01/01';
      _endDateController.text = '1403/12/29';
    });
    _loadLedgerEntries();
  }
}
