import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/components.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _initialBalanceController =
      TextEditingController();

  String? _selectedType;
  final List<String> _accountTypes = ['درآمد', 'هزینه', 'بانک', 'شخص'];

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _dbHelper.getAllAccountsWithDetails();
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت حساب‌ها'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // فرم افزودن حساب
            _buildAccountForm(),

            const SizedBox(height: 20),

            // لیست حساب‌ها
            _buildAccountsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'افزودن حساب جدید',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // فیلد نام حساب
            TextField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'نام حساب',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // انتخاب نوع حساب
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع حساب',
                border: OutlineInputBorder(),
              ),
              items: _accountTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
            ),

            const SizedBox(height: 12),

            // موجودی اولیه
            NumberTextField(
              controller: _initialBalanceController,
              hintText: 'موجودی اولیه (اختیاری)',
            ),

            const SizedBox(height: 16),

            // دکمه‌های فرم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('افزودن حساب'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    child: const Text('پاک کردن'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'لیست حساب‌ها:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_accounts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('حسابی یافت نشد. اولین حساب را اضافه کنید.'),
              ),
            ),
          )
        else
          ..._accounts.map((account) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _getAccountIcon(account['account_type']),
                title: Text(account['account_name']),
                subtitle: Text(
                    'نوع: ${account['account_type']} | موجودی اولیه: ${_formatNumber(account['initial_balance'])}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAccount(account['account_name']),
                ),
                onTap: () => _showAccountDetails(account),
              ),
            );
          }),
      ],
    );
  }

  Icon _getAccountIcon(String type) {
    switch (type) {
      case 'درآمد':
        return const Icon(Icons.arrow_upward, color: Colors.green);
      case 'هزینه':
        return const Icon(Icons.arrow_downward, color: Colors.red);
      case 'بانک':
        return const Icon(Icons.account_balance, color: Colors.blue);
      case 'شخص':
        return const Icon(Icons.person, color: Colors.orange);
      default:
        return const Icon(Icons.account_balance_wallet);
    }
  }

  String _formatNumber(dynamic number) {
    final numValue = number is int ? number : (number as num).toInt();
    return numValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _addAccount() {
    final name = _accountNameController.text.trim();
    final balanceText = _initialBalanceController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('لطفاً نام حساب را وارد کنید');
      return;
    }

    if (_selectedType == null) {
      _showErrorDialog('لطفاً نوع حساب را انتخاب کنید');
      return;
    }

    final balance =
        balanceText.isEmpty ? 0.0 : double.tryParse(balanceText) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'تأیید افزودن حساب',
        message: '''
نام حساب: $name
نوع حساب: $_selectedType
موجودی اولیه: ${_formatNumber(balance)}

آیا مطمئن هستید؟''',
        onConfirm: () async {
          await _confirmAddAccount(name, _selectedType!, balance);
        },
      ),
    );
  }

  Future<void> _confirmAddAccount(
      String name, String type, double balance) async {
    try {
      // استفاده مستقیم از Map بدون مدل
      final result = await _dbHelper.addAccount({
        'account_name': name,
        'account_type': type,
        'initial_balance': balance,
        'created_date': DateTime.now().toIso8601String(),
      });

      if (result['success'] == true) {
        _showSuccessDialog(result['message']);
        _clearForm();
        await _loadAccounts();
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('خطا در افزودن حساب: $e');
    }
  }

  void _deleteAccount(String accountName) async {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'تأیید حذف',
        message: 'آیا از حذف حساب "$accountName" مطمئن هستید؟',
        onConfirm: () async {
          await _confirmDeleteAccount(accountName);
        },
      ),
    );
  }

  Future<void> _confirmDeleteAccount(String accountName) async {
    try {
      final result = await _dbHelper.deleteAccount(accountName);

      if (result['success'] == true) {
        _showSuccessDialog(result['message']);
        await _loadAccounts();
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('خطا در حذف حساب: $e');
    }
  }

  void _showAccountDetails(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account['account_name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نوع: ${account['account_type']}'),
            Text('موجودی اولیه: ${_formatNumber(account['initial_balance'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _accountNameController.clear();
      _initialBalanceController.clear();
      _selectedType = null;
    });
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

  @override
  void dispose() {
    _accountNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }
}
