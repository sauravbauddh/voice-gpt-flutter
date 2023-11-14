import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    print("IN");
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAIAPI"
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content":
                    "Does this message want to generate an AI picture, image or anything similar? 2 plus 2 . Simply answer with yes or no",
              },
            ],
          },
        ),
      );

      print(response.body);

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        content = content.toLowerCase();

        if (content.contains("yes")) {
          final res = await dallEAPI(prompt);
          return res;
        } else {
          final res = await chatGPTAPI(prompt);
          return res;
        }
      }
    } catch (e) {
      return e.toString();
    }
    return "Internal Error Occurred";
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({"role": "user", "content": prompt});

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAIAPI"
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages,
          },
        ),
      );

      print(messages);

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        messages.add(
          {"role": "assistant", "content": content},
        );

        return content;
      }
    } catch (e) {
      print(e.toString());
    }

    return "CHATGPT";
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({"role": "user", "content": "prompt"});

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/images/generations"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAIAPI"
        },
        body: jsonEncode(
          {
            "prompt": prompt,
            "n": 1,
          },
        ),
      );

      if (response.statusCode == 200) {
        String imgUrl = jsonDecode(response.body)['data'][0]['url'];
        messages.add(
          {"role": "assistant", "content": imgUrl},
        );

        return imgUrl;
      }
    } catch (e) {
      print(e.toString());
    }
    return "DALLE";
  }
}
