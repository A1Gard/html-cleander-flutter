import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

late final Highlighter htmlDarkHighlighter;
late final Highlighter htmlLightHighlighter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Highlighter.initialize([
    'html',
  ]);

  final darkTheme = await HighlighterTheme.loadDarkTheme();
  final lightTheme = await HighlighterTheme.loadLightTheme();

  htmlDarkHighlighter = Highlighter(
    language: 'html',
    theme: darkTheme,
  );

  htmlLightHighlighter = Highlighter(
    language: 'html',
    theme: lightTheme,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HtmlEditorPage(),
    );
  }
}

class HtmlEditorPage extends StatefulWidget {
  const HtmlEditorPage({super.key});

  @override
  State<HtmlEditorPage> createState() => _HtmlEditorPageState();
}

class _HtmlEditorPageState extends State<HtmlEditorPage> {
  late final CodeEditorController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CodeEditorController(
      text: '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hello World</title>
</head>

<body>
  <div class="container">
    <h1>Hello World</h1>
    <p>This is an HTML example.</p>

    <button onclick="sayHello()">
      Click me
    </button>
  </div>

  <script>
    function sayHello() {
      console.log("Hello!");
    }
  </script>
</body>
</html>
''',
      lightHighlighter: htmlLightHighlighter,
      darkHighlighter: htmlDarkHighlighter,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('HTML Cleaner'),
        backgroundColor: const Color(0xFF161B22),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.70,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF30363D),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CodeEditor(
              controller: _controller,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
