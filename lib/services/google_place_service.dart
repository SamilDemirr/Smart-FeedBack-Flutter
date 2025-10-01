import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlaceService {
  final String apiKey;

  GooglePlaceService(this.apiKey);

  /// Place ID çekiyoruz
  Future<String?> fetchPlaceId(String businessName) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
      '?input=${Uri.encodeComponent(businessName)}'
      '&inputtype=textquery'
      '&fields=place_id'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    print("FIND_PLACE response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        return data['candidates'][0]['place_id'];
      } else {
        return null;
      }
    } else {
      throw Exception('Yer ID alınamadı');
    }
  }

  /// Yorumları çekiyoruz
  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=reviews,photos'
      '&language=tr'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['result'] != null) {
        return {
          'reviews': data['result']['reviews'] ?? [],
          'photos': data['result']['photos'] ?? [],
        };
      } else {
        throw Exception('İşletme bulunamadı veya içerik yok');
      }
    } else {
      throw Exception('Detaylar alınamadı');
    }
  }

  //   final response = await http.get(url);
  //   print("DETAILS response: ${response.body}");
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data['status'] == 'OK' && data['result'] != null) {
  //       return data['result']['reviews'] ?? [];
  //     } else {
  //       throw Exception('İşletme bulunamadı veya yorum yok');
  //     }
  //   } else {
  //     throw Exception('Yorumlar alınamadı');
  //   }
  // }
}
