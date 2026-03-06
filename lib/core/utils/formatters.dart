import 'package:intl/intl.dart';

/// Classe de formatadores para valores monetários, datas, telefones, etc
class Formatters {
  Formatters._();
  
  // ============ FORMATADORES DE MOEDA ============
  
  /// Formata valor para moeda brasileira
  /// Ex: 1234.56 => R$ 1.234,56
  static String currency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  /// Formata valor compacto
  /// Ex: 1500 => R$ 1,5K
  static String currencyCompact(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return currency(value);
  }
  
  /// Formata apenas o número sem símbolo
  /// Ex: 1234.56 => 1.234,56
  static String number(double value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }
  
  // ============ FORMATADORES DE DATA ============
  
  /// Formata data completa
  /// Ex: 01 de janeiro de 2024
  static String dateFullMonth(DateTime date) {
    final formatter = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');
    return formatter.format(date);
  }
  
  /// Formata data curta
  /// Ex: 01/01/2024
  static String dateShort(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }
  
  /// Formata data no formato dd MMM (ex: 15 Jan)
  static String date(DateTime date) {
    final formatter = DateFormat('dd MMM', 'pt_BR');
    return formatter.format(date);
  }
  
  /// Formata data e hora
  /// Ex: 01/01/2024 às 14:30
  static String dateTime(DateTime date) {
    final formatter = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
    return formatter.format(date);
  }
  
  /// Formata apenas hora
  /// Ex: 14:30
  static String time(DateTime date) {
    final formatter = DateFormat('HH:mm', 'pt_BR');
    return formatter.format(date);
  }
  
  /// Alias para dateRelative
  static String relativeTime(DateTime date) => dateRelative(date);
  
  /// Formata data relativa (há X minutos, há X horas, etc)
  static String dateRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Há $weeks sem${weeks > 1 ? 'anas' : 'ana'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Há $months ${months > 1 ? 'meses' : 'mês'}';
    } else {
      return dateShort(date);
    }
  }
  
  /// Formata tempo restante (countdown)
  static String timeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return 'Encerrado';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}min';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'Menos de 1 min';
    }
  }
  
  // ============ FORMATADORES DE TELEFONE ============
  
  /// Formata telefone brasileiro
  /// Ex: 11999999999 => (11) 99999-9999
  static String phone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
  
  // ============ FORMATADORES DE DOCUMENTO ============
  
  /// Formata CPF
  /// Ex: 12345678900 => 123.456.789-00
  static String cpf(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    return cpf;
  }
  
  /// Formata CNPJ
  /// Ex: 12345678000199 => 12.345.678/0001-99
  static String cnpj(String cnpj) {
    final digits = cnpj.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 14) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    return cnpj;
  }
  
  /// Formata CEP
  /// Ex: 12345678 => 12345-678
  static String cep(String cep) {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return cep;
  }
  
  // ============ FORMATADORES DE PORCENTAGEM ============
  
  /// Formata porcentagem
  /// Ex: 0.75 => 75%
  static String percentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
  
  /// Formata progresso (valor atual / total)
  static String progress(double current, double total) {
    final percent = total > 0 ? (current / total) : 0.0;
    return percentage(percent);
  }
  
  // ============ OUTROS FORMATADORES ============
  
  /// Trunca texto com reticências
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Formata nome (primeira letra maiúscula)
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Formata nome completo (capitaliza cada palavra)
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Formata distância em metros/km
  static String distance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
  
  // ============ FORMATADORES DE CHAVE PIX ============
  
  /// Formata chave PIX aleatória (UUID)
  /// Ex: 1234567890abcdef1234567890abcdef => 12345678-90ab-cdef-1234-567890abcdef
  static String pixKeyRandom(String value) {
    // Remove formatação existente
    final clean = value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
    
    if (clean.length != 32) {
      return value; // Retorna original se não tiver 32 caracteres
    }
    
    // Formata como UUID: 8-4-4-4-12
    return '${clean.substring(0, 8)}-${clean.substring(8, 12)}-${clean.substring(12, 16)}-${clean.substring(16, 20)}-${clean.substring(20)}';
  }
  
  /// Remove formatação de chave PIX aleatória
  static String pixKeyRandomUnformat(String value) {
    return value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
  }
}

