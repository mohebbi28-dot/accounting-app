import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  final String accountName;
  final double balance;
  final bool isCenter;

  const AccountCard({
    super.key,
    required this.accountName,
    required this.balance,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCenter ? 180 : 140,
      height: isCenter ? 90 : 70,
      decoration: BoxDecoration(
        color: isCenter ? Colors.teal : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getShortName(accountName),
            style: TextStyle(
              color: isCenter ? Colors.white : Colors.black87,
              fontSize: isCenter ? 16 : 14,
              fontWeight: isCenter ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatBalance(balance),
            style: TextStyle(
              color: isCenter ? Colors.white : Colors.grey[700],
              fontSize: isCenter ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getShortName(String name) {
    return name.length > 12 ? '${name.substring(0, 12)}...' : name;
  }

  String _formatBalance(double balance) {
    return '${balance.toStringAsFixed(0)}';
  }
}
