import 'package:flutter/material.dart';
import '../widgets/magnetic_slider.dart';
import '../utils/date_converter.dart';
import '../database/database_helper.dart';
import 'accounts_screen.dart';
import 'journal_screen.dart';
import 'ledger_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFromAccount;
  String? _selectedToAccount;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _fromAccounts = [];
  List<String> _toAccounts = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateConverter.getCurrentShamsiDate();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final fromAccs = await _dbHelper.getAccounts(accountType: 'from');
      final toAccs = await _dbHelper.getAccounts(accountType: 'to');

      setState(() {
        _fromAccounts = fromAccs;
        _toAccounts = toAccs;
      });
    } catch (e) {
      // اگر دیتابیس خطا داد، از داده‌های نمونه استفاده کن
      setState(() {
        _fromAccounts = ['نقد', 'بانک', 'کارت اعتباری'];
        _toAccounts = ['خوراک', 'اجاره', 'حمل و نقل'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابداری شخصی'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FROM Account Slider
            _buildAccountSection(
              title: 'حساب مبدا:',
              accounts: _fromAccounts,
              onAccountSelected: (account) {
                if (mounted) {
                  setState(() {
                    _selectedFromAccount = account;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // TO Account Slider
            _buildAccountSection(
              title: 'حساب مقصد:',
              accounts: _toAccounts,
              onAccountSelected: (account) {
                if (mounted) {
                  setState(() {
                    _selectedToAccount = account;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            _buildSelectedAccountsDisplay(),
            const SizedBox(height: 20),
            _buildTransactionForm(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection({
    required String title,
    required List<String> accounts,
    required Function(String) onAccountSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        MagneticSlider(
          accounts: accounts,
          onAccountSelected: onAccountSelected,
        ),
      ],
    );
  }

  Widget _buildSelectedAccountsDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'مبدا:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _selectedFromAccount ?? 'انتخاب نشده',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'مقصد:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _selectedToAccount ?? 'انتخاب نشده',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormField(
              label: 'تاریخ',
              controller: _dateController,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              label: 'مبلغ',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              label: 'توضیحات (اختیاری)',
              controller: _descriptionController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'ثبت تراکنش',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const JournalScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('دفتر روزنامه'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LedgerScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('دفتر کل'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('مدیریت حساب‌ها'),
          ),
        ),
      ],
    );
  }

  void _submitTransaction() async {
    if (_selectedFromAccount == null || _selectedToAccount == null) {
      _showErrorDialog('لطفاً حساب مبدا و مقصد را انتخاب کنید');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showErrorDialog('لطفاً مبلغ را وارد کنید');
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showErrorDialog('مبلغ باید بزرگتر از صفر باشد');
      return;
    }

    try {
      await _dbHelper.addTransaction({
        'transaction_date': _dateController.text,
        'from_account': _selectedFromAccount!,
        'to_account': _selectedToAccount!,
        'amount': amount,
        'description': _descriptionController.text,
      });

      _showSuccessDialog('تراکنش با موفقیت ثبت شد!');
      _resetForm();
      await _loadAccounts(); // رفرش لیست حساب‌ها
    } catch (e) {
      _showErrorDialog('خطا در ثبت تراکنش: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطا'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('موفق'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
