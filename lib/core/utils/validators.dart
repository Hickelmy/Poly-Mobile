/// Classe de validadores para formulários
class Validators {
  Validators._();
  
  /// Valida se o campo não está vazio
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName é obrigatório' 
          : 'Campo obrigatório';
    }
    return null;
  }
  
  /// Valida email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }
  
  /// Valida senha
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < minLength) {
      return 'Senha deve ter no mínimo $minLength caracteres';
    }
    return null;
  }
  
  /// Valida confirmação de senha
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirme a senha';
    }
    
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }
  
  /// Valida nome
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.trim().length < minLength) {
      return 'Nome deve ter no mínimo $minLength caracteres';
    }
    
    // Verifica se contém pelo menos duas palavras
    final words = value.trim().split(' ').where((w) => w.isNotEmpty);
    if (words.length < 2) {
      return 'Informe nome e sobrenome';
    }
    
    return null;
  }
  
  /// Valida telefone brasileiro
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone inválido';
    }
    
    // Valida DDD
    final ddd = int.tryParse(digits.substring(0, 2)) ?? 0;
    if (ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }
    
    return null;
  }
  
  /// Valida CPF
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) {
      return 'CPF inválido';
    }
    
    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(digits[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    
    if (int.parse(digits[9]) != firstDigit) {
      return 'CPF inválido';
    }
    
    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(digits[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    
    if (int.parse(digits[10]) != secondDigit) {
      return 'CPF inválido';
    }
    
    return null;
  }
  
  /// Valida CEP
  static String? cep(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }
    
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }
    
    return null;
  }
  
  /// Valida valor monetário
  static String? money(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Valor é obrigatório';
    }
    
    // Remove formatação e converte
    final cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    
    final numValue = double.tryParse(cleanValue);
    
    if (numValue == null) {
      return 'Valor inválido';
    }
    
    if (min != null && numValue < min) {
      return 'Valor mínimo: R\$ ${min.toStringAsFixed(2)}';
    }
    
    if (max != null && numValue > max) {
      return 'Valor máximo: R\$ ${max.toStringAsFixed(2)}';
    }
    
    return null;
  }
  
  /// Valida número inteiro
  static String? integer(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Valor é obrigatório';
    }
    
    final numValue = int.tryParse(value);
    
    if (numValue == null) {
      return 'Valor deve ser um número inteiro';
    }
    
    if (min != null && numValue < min) {
      return 'Valor mínimo: $min';
    }
    
    if (max != null && numValue > max) {
      return 'Valor máximo: $max';
    }
    
    return null;
  }
  
  /// Valida URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL opcional
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }
    
    return null;
  }
  
  /// Valida tamanho mínimo de texto
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return fieldName != null
          ? '$fieldName deve ter no mínimo $min caracteres'
          : 'Deve ter no mínimo $min caracteres';
    }
    return null;
  }
  
  /// Valida tamanho máximo de texto
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return fieldName != null
          ? '$fieldName deve ter no máximo $max caracteres'
          : 'Deve ter no máximo $max caracteres';
    }
    return null;
  }
  
  /// Combina múltiplos validadores
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }
}

