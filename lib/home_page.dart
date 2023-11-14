import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallette.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = "";
  String? generatedContent;
  String? generatedUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  final OpenAIService openAIService = OpenAIService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text("VoiceGPT"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //VA Picture
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                ),
              ],
            ),
            //Chat Bubble
            Visibility(
              visible: generatedUrl == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Pallete.borderColor),
                  borderRadius:
                      BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? "Good Morning, What task can I do for you?"
                        : generatedContent!,
                    style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontFamily: 'Cera Pro',
                        fontSize: generatedContent == null ? 25 : 18),
                  ),
                ),
              ),
            ),
            if (generatedUrl != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedUrl!),
                ),
              ),
            //suggestion
            Visibility(
              visible: generatedContent == null && generatedUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10, left: 22),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Here are a few features",
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //feature box
            Visibility(
              visible: generatedContent == null && generatedUrl == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: "ChatGPT",
                    descText:
                        "A smarter way to stay organized and informed with ChatGPT",
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: "DALL-E",
                    descText:
                        "Get inspired and stay creative with your personal assistant powered by DALL-E",
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: "Smart Voice Assistant",
                    descText:
                        "Get inspired and stay creative with your personal assistant powered by DALL-E and ChatGPT",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            print(lastWords);
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains("http")) {
              generatedUrl = speech;
              generatedContent = null;
              setState(() {});
            } else {
              generatedContent = speech;
              generatedUrl = null;
              setState(() {});
              await systemSpeak(speech);
            }
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
