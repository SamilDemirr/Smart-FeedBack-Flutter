import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> summarizeReviews(List<String> reviews) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final prompt =
        'Aşağıdaki müşteri yorumlarını incele ve yorumları özetleyen bir yorum çıkar bu yorumun içeriğinde işletmenin iyi ve kötü yönlerini söyle bu çıkarttığın özet sonucu işletmeye dair iyi ve kötü bilgilere sahip olmalıyım. Ve başka bir paragrafta işletmenin iyileştirilmesi gereken yönlerini söyle:\n\n' +
            reviews.map((e) => '- $e').join('\n');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.trim();
    } else {
      throw Exception('Özetleme başarısız: ${response.body}');
    }
  }
}
