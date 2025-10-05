extension NumX on num {
  String toCurrencyFormat({String? currencyName, int? decimalDigits}) {
    return '${this < 0 ? '-' : ''}\$${abs().toStringAsFixed(decimalDigits ?? 2)}';
  }
}

extension StringX on String {
  String removeVietnameseDiacritics() {
    const vietnamese = 'àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ';
    const withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    String str = toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(vietnamese[i], withoutDiacritics[i]);
    }
    return str;
  }
}