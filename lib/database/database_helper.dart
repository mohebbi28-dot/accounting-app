import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'accounting.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT UNIQUE NOT NULL,
        account_type TEXT NOT NULL,
        initial_balance REAL DEFAULT 0,
        created_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_date TEXT NOT NULL,
        from_account TEXT NOT NULL,
        to_account TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        created_date TEXT,
        entry_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT NOT NULL,
        transaction_date TEXT NOT NULL,
        from_account TEXT NOT NULL,
        to_account TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        balance REAL NOT NULL,
        created_date TEXT
      )
    ''');
  }

  // Accounts methods
  Future<List<String>> getAccounts(
      {String? accountType, String? excludeAccount}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (accountType == 'from') {
      whereClause = 'WHERE account_type IN (?, ?, ?) AND account_name != ?';
      whereArgs = ['درآمد', 'بانک', 'شخص', excludeAccount ?? ''];
    } else if (accountType == 'to') {
      whereClause = 'WHERE account_type IN (?, ?, ?) AND account_name != ?';
      whereArgs = ['هزینه', 'بانک', 'شخص', excludeAccount ?? ''];
    } else if (excludeAccount != null) {
      whereClause = 'WHERE account_name != ?';
      whereArgs = [excludeAccount];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      columns: ['account_name'],
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'account_name',
    );

    return maps.map((map) => map['account_name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getAllAccountsWithDetails() async {
    final db = await database;
    return await db.query(
      'accounts',
      columns: ['account_name', 'account_type', 'initial_balance'],
      orderBy: 'account_type, account_name',
    );
  }

  Future<Map<String, dynamic>?> getAccountDetails(String accountName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      columns: ['account_name', 'account_type', 'initial_balance'],
      where: 'account_name = ?',
      whereArgs: [accountName],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>> addAccount(
      Map<String, dynamic> accountData) async {
    final db = await database;
    try {
      await db.insert('accounts', {
        'account_name': accountData['account_name'],
        'account_type': accountData['account_type'],
        'initial_balance': accountData['initial_balance'],
        'created_date': accountData['created_date'],
      });
      return {'success': true, 'message': 'حساب با موفقیت افزوده شد.'};
    } catch (e) {
      return {'success': false, 'message': 'حساب با این نام از قبل وجود دارد.'};
    }
  }

  Future<Map<String, dynamic>> updateAccount(String oldAccountName,
      String newAccountName, String accountType, double initialBalance) async {
    final db = await database;
    try {
      await db.update(
        'accounts',
        {
          'account_name': newAccountName,
          'account_type': accountType,
          'initial_balance': initialBalance,
        },
        where: 'account_name = ?',
        whereArgs: [oldAccountName],
      );
      return {'success': true, 'message': 'حساب با موفقیت ویرایش شد.'};
    } catch (e) {
      return {'success': false, 'message': 'حساب با این نام از قبل وجود دارد.'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String accountName) async {
    final db = await database;

    // Check if account is used in transactions
    final transactionCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM journal WHERE (from_account = ? OR to_account = ?)',
            [accountName, accountName])) ??
        0;

    if (transactionCount > 0) {
      return {
        'success': false,
        'message':
            'حساب "$accountName" در $transactionCount تراکنش استفاده شده و قابل حذف نیست.'
      };
    }

    await db.delete(
      'accounts',
      where: 'account_name = ?',
      whereArgs: [accountName],
    );

    return {'success': true, 'message': 'حساب با موفقیت حذف شد.'};
  }

  // Journal methods
  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    final db = await database;

    // Get last entry order for the date
    final lastOrder = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT MAX(entry_order) FROM journal WHERE transaction_date = ?',
            [transactionData['transaction_date']])) ??
        0;

    await db.insert('journal', {
      'transaction_date': transactionData['transaction_date'],
      'from_account': transactionData['from_account'],
      'to_account': transactionData['to_account'],
      'amount': transactionData['amount'],
      'description': transactionData['description'],
      'created_date': DateTime.now().toIso8601String(),
      'entry_order': lastOrder + 1,
    });

    await _updateLedger(db, transactionData);
  }

  Future<void> _updateLedger(
      Database db, Map<String, dynamic> transactionData) async {
    // Update from account
    final fromBalanceResult = await db.rawQuery(
        'SELECT COALESCE(MAX(balance), 0) FROM ledger WHERE account_name = ?',
        [transactionData['from_account']]);
    final double fromBalance =
        (fromBalanceResult.first['COALESCE(MAX(balance), 0)'] as num)
                .toDouble() -
            transactionData['amount'];

    await db.insert('ledger', {
      'account_name': transactionData['from_account'],
      'transaction_date': transactionData['transaction_date'],
      'from_account': transactionData['from_account'],
      'to_account': transactionData['to_account'],
      'amount': -transactionData['amount'],
      'description': transactionData['description'],
      'balance': fromBalance,
      'created_date': DateTime.now().toIso8601String(),
    });

    // Update to account
    final toBalanceResult = await db.rawQuery(
        'SELECT COALESCE(MAX(balance), 0) FROM ledger WHERE account_name = ?',
        [transactionData['to_account']]);
    final double toBalance =
        (toBalanceResult.first['COALESCE(MAX(balance), 0)'] as num).toDouble() +
            transactionData['amount'];

    await db.insert('ledger', {
      'account_name': transactionData['to_account'],
      'transaction_date': transactionData['transaction_date'],
      'from_account': transactionData['from_account'],
      'to_account': transactionData['to_account'],
      'amount': transactionData['amount'],
      'description': transactionData['description'],
      'balance': toBalance,
      'created_date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getJournalEntries(
      {String? startDate, String? endDate}) async {
    final db = await database;

    if (startDate != null && endDate != null) {
      return await db.query(
        'journal',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'transaction_date, entry_order',
      );
    } else {
      return await db.query(
        'journal',
        orderBy: 'transaction_date DESC, entry_order DESC',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getLedgerEntries(
      {String? accountName, String? startDate, String? endDate}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (accountName != null) {
      whereClause = 'account_name = ?';
      whereArgs.add(accountName);

      if (startDate != null && endDate != null) {
        whereClause += ' AND transaction_date BETWEEN ? AND ?';
        whereArgs.addAll([startDate, endDate]);
      }
    } else if (startDate != null && endDate != null) {
      whereClause = 'transaction_date BETWEEN ? AND ?';
      whereArgs.addAll([startDate, endDate]);
    }

    return await db.query(
      'ledger',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: accountName != null
          ? 'transaction_date, id'
          : 'account_name, transaction_date, id',
    );
  }

  Future<double> getAccountBalance(String accountName) async {
    final db = await database;

    // Get initial balance
    final initialBalanceResult = await db.query(
      'accounts',
      columns: ['initial_balance'],
      where: 'account_name = ?',
      whereArgs: [accountName],
    );

    double initialBalance = 0;
    if (initialBalanceResult.isNotEmpty) {
      initialBalance =
          (initialBalanceResult.first['initial_balance'] as num).toDouble();
    }

    // Get ledger balance
    final ledgerBalanceResult = await db.rawQuery(
        'SELECT COALESCE(MAX(balance), 0) FROM ledger WHERE account_name = ?',
        [accountName]);

    double ledgerBalance =
        (ledgerBalanceResult.first['COALESCE(MAX(balance), 0)'] as num)
            .toDouble();

    return initialBalance + ledgerBalance;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
