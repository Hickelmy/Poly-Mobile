import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Tela completa de cadastro de produtos
class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  final List<File> _selectedImages = [];
  String? _category;
  String? _condition;
  double? _lat;
  double? _lng;
  bool _isLoadingLocation = false;
  bool _isUploadingImages = false;
  final ImagePicker _imagePicker = ImagePicker();
  final MapController _mapController = MapController();

  // Categorias disponíveis
  final List<String> _categories = [
    'eletronicos',
    'moveis',
    'vestuario',
    'alimentos',
    'artesanato',
    'outros',
  ];

  final Map<String, String> _categoryLabels = {
    'eletronicos': 'Eletrônicos',
    'moveis': 'Móveis',
    'vestuario': 'Vestuário',
    'alimentos': 'Alimentos',
    'artesanato': 'Artesanato',
    'outros': 'Outros',
  };

  // Condições disponíveis
  final List<String> _conditions = [
    'novo',
    'usado_otimo',
    'usado_bom',
    'usado_regular',
  ];

  final Map<String, String> _conditionLabels = {
    'novo': 'Novo',
    'usado_otimo': 'Usado - Ótimo',
    'usado_bom': 'Usado - Bom',
    'usado_regular': 'Usado - Regular',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// Arredonda coordenadas para privacidade (3 casas decimais = ~100m)
  double _roundCoordinate(double coord) {
    return (coord * 1000).roundToDouble() / 1000;
  }

  /// Captura localização do usuário
  Future<void> _getLocation() async {
    if (_isLoadingLocation || !mounted) return;

    setState(() => _isLoadingLocation = true);

    try {
      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ative o GPS nas configurações do dispositivo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verifica e solicita permissão
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permissão negada permanentemente. Ative nas configurações.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Obtém localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = _roundCoordinate(position.latitude);
      final lng = _roundCoordinate(position.longitude);

      if (!mounted) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Verifica se o mapa já está renderizado (lat/lng já existiam antes)
      final mapWasAlreadyVisible = _lat != null && _lng != null;

      setState(() {
        _lat = lat;
        _lng = lng;
        _isLoadingLocation = false;
      });

      // Só move o mapa se ele já estava visível
      // Se é a primeira vez, o mapa será criado com a posição correta via initialCenter
      if (mapWasAlreadyVisible) {
        // Usa post-frame callback para garantir que o mapa está pronto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              _mapController.move(LatLng(lat, lng), 13);
            } catch (_) {
              // Ignora erro se o mapa não estiver pronto
            }
          }
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização capturada com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 100),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (!mounted) return;

      String errorMessage = 'Erro ao obter localização';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('permission') ||
          errorString.contains('permissão')) {
        errorMessage =
            'Permissão de localização negada. Ative nas configurações.';
      } else if (errorString.contains('service') ||
          errorString.contains('gps')) {
        errorMessage = 'Serviço de localização desativado. Ative o GPS.';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Tempo esgotado. Verifique o GPS e tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Mostra diálogo para escolher entre galeria ou câmera
  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        // Seleciona múltiplas imagens da galeria
        final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
          imageQuality: 85,
        );

        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
          });
        }
      } else {
        // Tira foto com a câmera
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );

        if (photo != null) {
          setState(() {
            _selectedImages.add(File(photo.path));
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove imagem
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Converte imagens para base64 e retorna array de strings base64
  Future<List<String>> _convertImagesToBase64() async {
    if (_selectedImages.isEmpty) return [];

    setState(() => _isUploadingImages = true);
    final List<String> base64Images = [];

    try {
      for (final imageFile in _selectedImages) {
        // Lê os bytes do arquivo
        final bytes = await imageFile.readAsBytes();

        // Determina o tipo MIME baseado na extensão
        String mimeType = 'image/jpeg';
        final extension = imageFile.path.toLowerCase();
        if (extension.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (extension.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (extension.endsWith('.webp')) {
          mimeType = 'image/webp';
        }

        // Converte para base64
        final base64String = base64Encode(bytes);

        // Formato: data:image/jpeg;base64,...
        final dataUrl = 'data:$mimeType;base64,$base64String';
        base64Images.add(dataUrl);
      }

      setState(() => _isUploadingImages = false);
      return base64Images;
    } catch (e) {
      setState(() => _isUploadingImages = false);
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar imagens: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  /// Cria o produto
  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capture a localização aproximada do produto'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 100),
        ),
      );
      return;
    }

    final provider = context.read<ProductsProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para criar um produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Converte imagens para base64
    final imageBase64List = await _convertImagesToBase64();

    final product = await provider.createProduct(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      quantityAvailable: int.parse(_quantityController.text),
      category: _category,
      condition: _condition ?? 'novo',
      images: imageBase64List,
      lat: _lat,
      lng: _lng,
    );

    if (!mounted) return;

    if (product != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto criado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao criar produto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagens
                      _buildImagesSection(),
                      const SizedBox(height: 24),

                      // Nome
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          hintText: 'Nome do produto',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Descreva seu produto',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Preço e Quantidade
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Preço (R\$) *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isEmpty == true
                                  ? 'Campo obrigatório'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Categoria e Condição
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                      _categoryLabels[category] ?? category),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _category = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _condition ?? 'novo',
                              decoration: const InputDecoration(
                                labelText: 'Condição',
                                border: OutlineInputBorder(),
                              ),
                              items: _conditions.map((condition) {
                                return DropdownMenuItem(
                                  value: condition,
                                  child: Text(
                                      _conditionLabels[condition] ?? condition),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _condition = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Localização
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Botão fixo na parte inferior
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.slate700 : AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Consumer<ProductsProvider>(
                  builder: (context, provider, _) {
                    return CustomButton(
                      text: 'Criar Produto',
                      onPressed: _createProduct,
                      isLoading: provider.isLoading || _isUploadingImages,
                      isFullWidth: true,
                      backgroundColor: AppColors.productColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seção de imagens
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagens',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Adicionar Imagens'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Seção de localização
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização Aproximada *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: _isLoadingLocation
              ? 'Capturando...'
              : (_lat != null && _lng != null
                  ? 'Atualizar Localização'
                  : 'Capturar Localização'),
          icon: Icons.location_on,
          onPressed: _isLoadingLocation ? null : _getLocation,
          isLoading: _isLoadingLocation,
          isFullWidth: true,
          backgroundColor: AppColors.productColor,
        ),
        if (_lat != null && _lng != null) ...[
          const SizedBox(height: 12),
          // Mapa com círculos de alcance
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(_lat!, _lng!),
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.polys_mobile',
                  ),
                  // Círculos de alcance
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(_lat!, _lng!),
                        radius: 500,
                        color: const Color(0xFF22c55e).withOpacity(0.1),
                        borderColor: const Color(0xFF22c55e),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                      CircleMarker(
                        point: LatLng(_lat!, _lng!),
                        radius: 1000,
                        color: const Color(0xFF16a34a).withOpacity(0.08),
                        borderColor: const Color(0xFF16a34a),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                      CircleMarker(
                        point: LatLng(_lat!, _lng!),
                        radius: 1500,
                        color: const Color(0xFF15803d).withOpacity(0.06),
                        borderColor: const Color(0xFF15803d),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
                  // Marcador de localização
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_lat!, _lng!),
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.productColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.productColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Círculos verdes mostram a área de alcance: 500m, 1km e 1.5km',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
