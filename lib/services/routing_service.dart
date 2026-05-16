import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  // Free public OSRM API
  static const String _osrmBaseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final String url = '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
          
          return coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
        }
      }
      
      print('Failed to fetch route: ${response.statusCode}');
      return [start, end]; // Fallback to direct line
    } catch (e) {
      print('Error fetching route: $e');
      return [start, end]; // Fallback to direct line
    }
  }

  // Calculate distance via road (meters)
  Future<double> getRouteDistance(LatLng start, LatLng end) async {
     try {
      final String url = '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return data['routes'][0]['distance'].toDouble();
        }
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
