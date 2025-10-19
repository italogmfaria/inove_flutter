class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  // Password strength validation (letras e números)
  static String? passwordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);

    if (!hasNumber || !hasLetter) {
      return 'A senha deve conter letras e números';
    }
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Min length validation
  static String? minLength(String? value, int min, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < min) {
      return '$fieldName deve ter no mínimo $min caracteres';
    }
    return null;
  }

  // CPF validation
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    final cpfClean = _cleanCpf(value);

    if (cpfClean.length != 11) {
      return 'CPF inválido';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfClean)) {
      return 'CPF inválido';
    }

    // Valida primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpfClean[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    if (digit1 != int.parse(cpfClean[9])) {
      return 'CPF inválido';
    }

    // Valida segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpfClean[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    if (digit2 != int.parse(cpfClean[10])) {
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

  // Code validation
  static String? code(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Código é obrigatório';
    }
    if (value.length != length) {
      return 'Código deve ter $length dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Código deve conter apenas números';
    }
    return null;
  }

  // Helper para limpar CPF
  static String _cleanCpf(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
}
