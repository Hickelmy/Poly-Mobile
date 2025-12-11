import 'dart:convert';
import 'package:flutter/material.dart';

/// Utilitários para manipulação de imagens
class ImageUtils {
  /// Verifica se uma string é uma imagem base64
  static bool isBase64Image(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    
    // Verifica se começa com data:image ou é base64 puro
    return imageUrl.startsWith('data:image/') || 
           imageUrl.startsWith('data:image%2F') ||
           (!imageUrl.startsWith('http://') && 
            !imageUrl.startsWith('https://') &&
            imageUrl.length > 100); // Base64 geralmente é longo
  }

  /// Converte base64 para ImageProvider
  static ImageProvider? getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Se for URL normal, retorna NetworkImage
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }

    // Se for base64
    if (isBase64Image(imageUrl)) {
      try {
        String base64String = imageUrl;
        
        // Remove prefixo data:image/...;base64, se existir
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        
        // Decodifica base64
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Cria widget de imagem que suporta base64 e URLs
  static Widget buildImage({
    required String? imageUrl,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return errorWidget ?? const SizedBox();
    }

    final provider = getImageProvider(imageUrl);
    
    if (provider == null) {
      return errorWidget ?? const SizedBox();
    }

    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.broken_image);
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return frame == null
            ? placeholder ?? const Center(child: CircularProgressIndicator())
            : child;
      },
    );
  }
}

