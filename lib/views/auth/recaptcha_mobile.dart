import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens a bottom sheet with a reCAPTCHA v2 ("I'm not a robot") challenge.
/// Returns the response token when solved, or null if the user closes it.
Future<String?> showRecaptcha(
  BuildContext context, {
  required String siteKey,
  String baseUrl = 'https://localhost', // must be a domain allowed on your key
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _RecaptchaSheet(siteKey: siteKey, baseUrl: baseUrl),
  );
}

class _RecaptchaSheet extends StatefulWidget {
  final String siteKey;
  final String baseUrl;

  const _RecaptchaSheet({required this.siteKey, required this.baseUrl});

  @override
  State<_RecaptchaSheet> createState() => _RecaptchaSheetState();
}

class _RecaptchaSheetState extends State<_RecaptchaSheet> {
  late final WebViewController _controller;
  bool _loading = true;

  String get _html => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  <style>
    body { margin: 0; padding-top: 24px; display: flex; justify-content: center; }
  </style>
</head>
<body>
  <div class="g-recaptcha"
       data-sitekey="${widget.siteKey}"
       data-callback="onSuccess"
       data-expired-callback="onExpired"></div>
  <script>
    function onSuccess(token) { Captcha.postMessage(token); }
    function onExpired() { Captcha.postMessage(''); }
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..addJavaScriptChannel(
        'Captcha',
        onMessageReceived: (msg) {
          final token = msg.message;
          if (token.isNotEmpty && mounted) Navigator.of(context).pop(token);
        },
      )
      ..loadHtmlString(_html, baseUrl: widget.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Verify you are human',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Android / iOS: a styled "I'm not a robot" box. Tapping it opens the
/// reCAPTCHA challenge in a sheet (the challenge needs more room than the box).
class RecaptchaBox extends StatefulWidget {
  final String siteKey;
  final ValueChanged<String?> onChanged;

  const RecaptchaBox({
    super.key,
    required this.siteKey,
    required this.onChanged,
  });

  @override
  State<RecaptchaBox> createState() => _RecaptchaBoxState();
}

class _RecaptchaBoxState extends State<RecaptchaBox> {
  static const _purple = Color(0xFF4A0A7A);
  String? _token;

  Future<void> _open() async {
    final token = await showRecaptcha(context, siteKey: widget.siteKey);
    if (token != null && mounted) {
      setState(() => _token = token);
      widget.onChanged(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _token != null;
    return GestureDetector(
      onTap: done ? null : _open,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_box : Icons.check_box_outline_blank,
              color: done ? _purple : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'I’m not a robot',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1C3AA9),
                      Color(0xFF4285F4),
                      Color(0xFFABABAB),
                      Color(0xFFABABAB),
                    ],
                    stops: [0.0, 0.5, 0.5, 1.0],
                  ).createShader(rect),
                  child: const Icon(Icons.sync, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 2),
                const Text('reCAPTCHA',
                    style: TextStyle(fontSize: 8, color: Colors.black54)),
                const Text('Privacy - Terms',
                    style: TextStyle(fontSize: 6, color: Colors.black45)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}