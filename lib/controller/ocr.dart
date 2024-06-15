import 'package:http/http.dart' as http;

class ResiOCR {
  final String provider;

  ResiOCR({required this.provider});
  Future<Map<String, String>> ocr(String urlOcr) async {
    String response = await httpOcr(urlOcr);
    if (provider == "Tokopedia") {
      return tokopediaOCR(response);
    } else if (provider == "Shopee") {
      return shopeeOCR(response);
    } else if (provider == "TikTok") {
      return tiktokOCR(response);
    } else {
      return {"penerima": "", "noResi": ""};
    }
  }

  Future<String> httpOcr(String urlOcr) async {
    final url = Uri.parse('https://api.ocr.space/parse/image');
    final response = await http.post(
      url,
      headers: {
        'apikey': 'K88665621688957',
      },
      body: {
        'language': 'eng',
        'url': "$urlOcr.pdf",
        'scale': 'true',
      },
    );

    return response.body;
  }

  Map<String, String> tokopediaOCR(String response) {
    String cleanedString = response.replaceAll(r'\r\n', '\n');
    String penerima =
        cleanedString.split("Penerima: ")[1].split("\n")[0].trim();
    String noResi =
        cleanedString.split("No.pesanan: ")[1].split("\n")[0].trim();

    return {
      "penerima": penerima,
      "noResi": noResi,
    };
  }

  Map<String, String> shopeeOCR(String response) {
    String cleanedString = response.replaceAll(r'\r\n', '\n');
    String penerima =
        cleanedString.split("Penerima: ")[1].split("\n")[0].trim();
    String noResi =
        cleanedString.split("No.pesanan: ")[1].split("\n")[0].trim();

    return {
      "penerima": penerima,
      "noResi": noResi,
    };
  }

  Map<String, String> tiktokOCR(String response) {
    String cleanedString = response.replaceAll(r'\r\n', '\n');
    String penerima =
        cleanedString.split("Penerima: ")[1].split("\n")[0].trim();
    String noResi =
        cleanedString.split("No.pesanan: ")[1].split("\n")[0].trim();

    return {
      "penerima": penerima,
      "noResi": noResi,
    };
  }
}
