import 'package:flutter/services.dart';

class Formatters {
  // Phone formatter: (00) 00000-0000
  static TextInputFormatter phone() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;

      StringBuffer formatted = StringBuffer();

      if (text.length >= 1) {
        formatted.write('(');
        formatted.write(text.substring(0, text.length > 2 ? 2 : text.length));
        if (text.length >= 2) {
          formatted.write(') ');
          if (text.length <= 6) {
            formatted.write(text.substring(2));
          } else {
            formatted.write(text.substring(2, text.length > 6 ? 6 : text.length));
            if (text.length > 6) {
              formatted.write('-');
              formatted.write(text.substring(6, text.length > 10 ? 10 : text.length));
            }
          }
        }
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // CPF formatter: 000.000.000-00
  static TextInputFormatter cpf() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;
      if (text.length > 11) {
        return oldValue;
      }

      StringBuffer formatted = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          formatted.write('.');
        } else if (i == 9) {
          formatted.write('-');
        }
        formatted.write(text[i]);
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // CNPJ formatter: 00.000.000/0000-00
  static TextInputFormatter cnpj() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;
      if (text.length > 14) {
        return oldValue;
      }

      StringBuffer formatted = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 5) {
          formatted.write('.');
        } else if (i == 8) {
          formatted.write('/');
        } else if (i == 12) {
          formatted.write('-');
        }
        formatted.write(text[i]);
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Date formatter: 00/00/0000
  static TextInputFormatter date() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isEmpty) return newValue;
      if (text.length > 8) {
        return oldValue;
      }

      StringBuffer formatted = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 4) {
          formatted.write('/');
        }
        formatted.write(text[i]);
      }

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }
}

