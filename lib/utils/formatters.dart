class Formatters {
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  static String formatCurrency(double amount) {
    return formatNumber(amount.toInt());
  }

  static String getAccountTypeDisplay(String type) {
    switch (type) {
      case 'درآمد':
        return 'Income';
      case 'هزینه':
        return 'Expense';
      case 'بانک':
        return 'Bank';
      case 'شخص':
        return 'Person';
      default:
        return type;
    }
  }

  static String shortenText(String text, {int maxLength = 12}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
