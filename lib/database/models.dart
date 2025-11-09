class Account {
  final int? id;
  final String accountName;
  final String accountType;
  final double initialBalance;
  final DateTime createdDate;

  Account({
    this.id,
    required this.accountName,
    required this.accountType,
    this.initialBalance = 0,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_name': accountName,
      'account_type': accountType,
      'initial_balance': initialBalance,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      accountName: map['account_name'],
      accountType: map['account_type'],
      initialBalance: map['initial_balance']?.toDouble() ?? 0,
      createdDate: DateTime.parse(map['created_date']),
    );
  }
}

class JournalEntry {
  final int? id;
  final String transactionDate;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String? description;
  final DateTime createdDate;
  final int entryOrder;

  JournalEntry({
    this.id,
    required this.transactionDate,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    this.description,
    required this.createdDate,
    this.entryOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_date': transactionDate,
      'from_account': fromAccount,
      'to_account': toAccount,
      'amount': amount,
      'description': description,
      'created_date': createdDate.toIso8601String(),
      'entry_order': entryOrder,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      transactionDate: map['transaction_date'],
      fromAccount: map['from_account'],
      toAccount: map['to_account'],
      amount: map['amount']?.toDouble() ?? 0,
      description: map['description'],
      createdDate: DateTime.parse(map['created_date']),
      entryOrder: map['entry_order'] ?? 0,
    );
  }
}

class LedgerEntry {
  final int? id;
  final String accountName;
  final String transactionDate;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String? description;
  final double balance;
  final DateTime createdDate;

  LedgerEntry({
    this.id,
    required this.accountName,
    required this.transactionDate,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    this.description,
    required this.balance,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_name': accountName,
      'transaction_date': transactionDate,
      'from_account': fromAccount,
      'to_account': toAccount,
      'amount': amount,
      'description': description,
      'balance': balance,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'],
      accountName: map['account_name'],
      transactionDate: map['transaction_date'],
      fromAccount: map['from_account'],
      toAccount: map['to_account'],
      amount: map['amount']?.toDouble() ?? 0,
      description: map['description'],
      balance: map['balance']?.toDouble() ?? 0,
      createdDate: DateTime.parse(map['created_date']),
    );
  }
}
