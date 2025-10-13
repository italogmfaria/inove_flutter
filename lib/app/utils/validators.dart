class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final phoneRegex = RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefone inválido';
    }
    return null;
  }

  // CPF validation
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    final cpfClean = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfClean.length != 11) {
      return 'CPF inválido';
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // Code validation (for verification)
  static String? code(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Código é obrigatório';
    }
    if (value.length != length) {
      return 'Código deve ter $length dígitos';
    }
    return null;
  }
}
