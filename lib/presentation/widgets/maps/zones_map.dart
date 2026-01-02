import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/zone_model.dart';

/// Widget de mapa interativo mostrando as zonas
class ZonesMap extends StatelessWidget {
  final List<ZoneModel> zones;
  final double height;
  final Function(ZoneModel)? onZoneTap;
  final LatLng? initialCenter;
  final double initialZoom;

  const ZonesMap({
    super.key,
    required this.zones,
    this.height = 250,
    this.onZoneTap,
    this.initialCenter,
    this.initialZoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calcular centro do mapa baseado nas zonas ou usar padrão
    LatLng center =
        initialCenter ?? const LatLng(-23.5505, -46.6333); // São Paulo padrão

    if (zones.isNotEmpty) {
      final zonesWithCenter = zones.where((z) => z.hasCenter).toList();
      if (zonesWithCenter.isNotEmpty) {
        double avgLat =
            zonesWithCenter.map((z) => z.centerLat!).reduce((a, b) => a + b) /
                zonesWithCenter.length;
        double avgLng =
            zonesWithCenter.map((z) => z.centerLng!).reduce((a, b) => a + b) /
                zonesWithCenter.length;
        center = LatLng(avgLat, avgLng);
      }
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: initialZoom,
            minZoom: 10.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (tapPosition, point) {
              // Verificar se clicou em alguma zona
              ZoneModel? tappedZone;

              // Primeiro verifica se está dentro de algum polígono
              for (var zone in zones) {
                if (zone.hasPolygon && zone.active) {
                  if (_isPointInPolygon(
                      point.latitude, point.longitude, zone.polygonGeojson!)) {
                    tappedZone = zone;
                    break;
                  }
                }
              }

              // Se não encontrou por polígono, verifica proximidade do centro
              if (tappedZone == null) {
                for (var zone in zones) {
                  if (zone.hasCenter && zone.active) {
                    final distance = const Distance().as(
                      LengthUnit.Meter,
                      point,
                      LatLng(zone.centerLat!, zone.centerLng!),
                    );
                    if (distance < 1000) {
                      tappedZone = zone;
                      break;
                    }
                  }
                }
              }

              if (tappedZone != null && onZoneTap != null) {
                onZoneTap!(tappedZone);
              }
            },
          ),
          children: [
            // Tile layer (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.polys.mobile',
              maxZoom: 19,
            ),

            // Zonas como polígonos ou marcadores
            if (zones.isNotEmpty)
              PolygonLayer(
                polygons:
                    zones.where((z) => z.hasPolygon && z.active).map((zone) {
                  // Extrair coordenadas do GeoJSON
                  List<LatLng> points = [];
                  if (zone.polygonGeojson != null) {
                    final coordinates = zone.polygonGeojson!['coordinates'];
                    if (coordinates != null && coordinates is List) {
                      // GeoJSON pode ter formato diferente
                      final coords = coordinates[0] ?? coordinates;
                      if (coords is List) {
                        for (var coord in coords) {
                          if (coord is List && coord.length >= 2) {
                            points.add(LatLng(
                              coord[1].toDouble(),
                              coord[0].toDouble(),
                            ));
                          }
                        }
                      }
                    }
                  }

                  // Se não tem polígono mas tem centro, criar um círculo pequeno
                  if (points.isEmpty && zone.hasCenter) {
                    // Criar um círculo ao redor do centro
                    const radius = 0.01; // ~1km
                    for (int i = 0; i < 32; i++) {
                      final angle = (i * 360 / 32) * math.pi / 180;
                      points.add(LatLng(
                        zone.centerLat! + radius * math.cos(angle),
                        zone.centerLng! + radius * math.sin(angle),
                      ));
                    }
                  }

                  return Polygon(
                    points: points,
                    color: _parseColor(zone.color).withOpacity(0.3),
                    borderColor: _parseColor(zone.color),
                    borderStrokeWidth: 2,
                    isFilled: true,
                  );
                }).toList(),
              ),

            // Marcadores de centro das zonas
            if (zones.isNotEmpty)
              MarkerLayer(
                markers:
                    zones.where((z) => z.hasCenter && z.active).map((zone) {
                  return Marker(
                    point: LatLng(zone.centerLat!, zone.centerLng!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => onZoneTap?.call(zone),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _parseColor(zone.color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            zone.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    String hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Verifica se um ponto está dentro de um polígono (GeoJSON)
  bool _isPointInPolygon(double lat, double lng, Map<String, dynamic> geojson) {
    try {
      final coordinates = geojson['coordinates'];
      if (coordinates == null || coordinates is! List) return false;

      // GeoJSON pode ter formato: [[[lng, lat], ...]] ou [[lng, lat], ...]
      List<List<dynamic>> polygon;
      if (coordinates[0] is List && coordinates[0][0] is List) {
        polygon = List<List<dynamic>>.from(coordinates[0]);
      } else {
        polygon = List<List<dynamic>>.from(coordinates);
      }

      if (polygon.isEmpty) return false;

      // Algoritmo ray casting
      bool inside = false;
      for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
        final xi = polygon[i][0] is num
            ? polygon[i][0].toDouble()
            : double.parse(polygon[i][0].toString());
        final yi = polygon[i][1] is num
            ? polygon[i][1].toDouble()
            : double.parse(polygon[i][1].toString());
        final xj = polygon[j][0] is num
            ? polygon[j][0].toDouble()
            : double.parse(polygon[j][0].toString());
        final yj = polygon[j][1] is num
            ? polygon[j][1].toDouble()
            : double.parse(polygon[j][1].toString());

        final intersect = ((yi > lng) != (yj > lng)) &&
            (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
      }

      return inside;
    } catch (e) {
      return false;
    }
  }
}
