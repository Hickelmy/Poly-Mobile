import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

/// Classe com funções auxiliares gerais
class Helpers {
  Helpers._();
  
  /// Gera um ID único
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// Copia texto para a área de transferência
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  /// Abre URL no navegador
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
  
  /// Abre WhatsApp com mensagem
  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final whatsappUrl = 'https://wa.me/55$cleanPhone${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}';
    return openUrl(whatsappUrl);
  }
  
  /// Faz ligação telefônica
  static Future<bool> makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    return openUrl('tel:+55$cleanPhone');
  }
  
  /// Envia email
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    return openUrl(uri.toString());
  }
  
  /// Abre Google Maps com coordenadas
  static Future<bool> openMaps(double lat, double lng, {String? label}) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng${label != null ? '&query_place_id=$label' : ''}';
    return openUrl(url);
  }
  
  /// Calcula distância entre duas coordenadas (em metros)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // metros
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
  
  /// Retorna saudação baseada na hora do dia
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }
  
  /// Retorna as iniciais do nome
  static String getInitials(String name) {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
  
  /// Gera cor baseada em string (para avatares)
  static Color getColorFromString(String text) {
    final hash = text.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.productColor,
      AppColors.serviceColor,
      AppColors.info,
      AppColors.success,
    ];
    return colors[hash.abs() % colors.length];
  }
  
  /// Debounce function
  static Function(T) debounce<T>(
    Duration duration,
    void Function(T) callback,
  ) {
    DateTime? lastCall;
    
    return (T value) {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) >= duration) {
        lastCall = now;
        callback(value);
      }
    };
  }
  
  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    return diagonal > 1100;
  }
  
  /// Retorna o número de colunas para grid responsivo
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 2;
  }
  
  /// Parseia JSON de forma segura
  static T? safeParseJson<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
    if (json == null) return null;
    if (json is! Map<String, dynamic>) return null;
    try {
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }
  
  /// Retorna lista de valores de enum como strings
  static List<String> enumValues<T extends Enum>(List<T> values) {
    return values.map((e) => e.name).toList();
  }
}

