import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

late final Highlighter htmlDarkHighlighter;
late final Highlighter htmlLightHighlighter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Highlighter.initialize(['html']);

  final darkTheme = await HighlighterTheme.loadDarkTheme();
  final lightTheme = await HighlighterTheme.loadLightTheme();

  htmlDarkHighlighter = Highlighter(language: 'html', theme: darkTheme);

  htmlLightHighlighter = Highlighter(language: 'html', theme: lightTheme);

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

  bool removeSpan = true;
  bool removeAuto = true;
  bool removeButton = true;
  bool removeCodeTag = true;
  bool removeComments = true;
  bool removeDivs = true;
  bool removeIds = true;

  String cleanHtml(String text) {
    String s = text;

    // 1) Remove HTML comments <!-- ... -->
    if (removeComments) {
      s = s.replaceAll(
        RegExp(r'<!--.*?-->', dotAll: true),
        '',
      );
    }

    // 2) Remove <span> tags that have NO attributes
    //    Keep inner content
    if (removeSpan) {
      final regex = RegExp(
        r'<span\s*>(.*?)</span>',
        caseSensitive: false,
        dotAll: true,
      );

      String old;
      do {
        old = s;
        s = s.replaceAllMapped(regex, (match) {
          return match.group(1) ?? '';
        });
      } while (s != old);
    }

    // 3) Remove dir="auto" or dir='auto' from ALL tags
    if (removeAuto) {
      s = s.replaceAll(
        RegExp(r'\s+dir\s*=\s*"auto"', caseSensitive: false),
        '',
      );

      s = s.replaceAll(
        RegExp(r"\s+dir\s*=\s*'auto'", caseSensitive: false),
        '',
      );
    }

    // 4) Remove <button ...>...</button>
    //    including content
    if (removeButton) {
      s = s.replaceAll(
        RegExp(
          r'<button\b[^>]*>.*?</button\s*>',
          caseSensitive: false,
          dotAll: true,
        ),
        '',
      );

      // Self-closing button
      s = s.replaceAll(
        RegExp(
          r'<button\b[^>]*/?>',
          caseSensitive: false,
        ),
        '',
      );
    }

    // 5) Remove class attribute from <code> tags
    if (removeCodeTag) {
      s = s.replaceAllMapped(
        RegExp(
          r'(<code\b[^>]*?)\s+class\s*=\s*"[^"]*"([^>]*>)',
          caseSensitive: false,
        ),
            (match) => '${match.group(1)}${match.group(2)}',
      );

      s = s.replaceAllMapped(
        RegExp(
          r"(<code\b[^>]*?)\s+class\s*=\s*'[^']*'([^>]*>)",
          caseSensitive: false,
        ),
            (match) => '${match.group(1)}${match.group(2)}',
      );
    }

    // 6) Remove <div> tags, keep inner content
    if (removeDivs) {
      s = s.replaceAll(
        RegExp(r'<div\b[^>]*>', caseSensitive: false),
        '',
      );

      s = s.replaceAll(
        RegExp(r'</div\s*>', caseSensitive: false),
        '',
      );
    }

    // 7) Remove id="..." or id='...' from ALL tags
    if (removeIds) {
      s = s.replaceAll(
        RegExp(r'\s+id\s*=\s*"[^"]*"', caseSensitive: false),
        '',
      );

      s = s.replaceAll(
        RegExp(r"\s+id\s*=\s*'[^']*'", caseSensitive: false),
        '',
      );
    }

    return s;
  }

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
      body: Container(
        padding: .fromLTRB(0, 10, 0, 0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 410,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF30363D)),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: .fromLTRB(5, 15, 0, 15),
                    child: Column(
                      spacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['html', 'htm', 'txt'],
                            );

                            if (result == null) return;

                            final path = result.files.single.path;

                            if (path == null) return;

                            final content = await File(path).readAsString();

                            _controller.text = content;

                            // اینجا content را هر کاری خواستی انجام بده
                          },
                          child: Padding(
                            padding: .all(20),
                            child: Row(
                              mainAxisAlignment: .center,
                              spacing: 10,
                              children: [
                                Icon(Icons.file_open_outlined),
                                Text("Open file"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: .fromLTRB(0, 15, 0, 10),
                        child: const Text('Options:'),
                      ),
                      _option(
                        'Remove Span has no attr',
                        removeSpan,
                        (v) => setState(() => removeSpan = v),
                      ),
                      _option(
                        'Remove auto',
                        removeAuto,
                        (v) => setState(() => removeAuto = v),
                      ),
                      _option(
                        'Remove button',
                        removeButton,
                        (v) => setState(() => removeButton = v),
                      ),
                      _option(
                        'Remove code tag class',
                        removeCodeTag,
                        (v) => setState(() => removeCodeTag = v),
                      ),
                      _option(
                        'Remove Comments',
                        removeComments,
                        (v) => setState(() => removeComments = v),
                      ),
                      _option(
                        'Remove Divs',
                        removeDivs,
                        (v) => setState(() => removeDivs = v),
                      ),
                      _option(
                        'Remove IDs',
                        removeIds,
                        (v) => setState(() => removeIds = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.text = cleanHtml(_controller.text);
        },
        child: Icon(Icons.cleaning_services_rounded),
      ),
      floatingActionButtonLocation: .startFloat,
    );
  }
}

Widget _option(String title, bool value, ValueChanged<bool> onChanged) {
  return InkWell(
    onTap: () => onChanged(!value),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: .fromLTRB(10, 0, 0, 0),
              child: Text(title, overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 4),
          Transform.scale(
            scale: 0.75,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    ),
  );
}
