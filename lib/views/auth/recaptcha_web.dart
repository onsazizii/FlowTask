import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web: the real Google reCAPTCHA v2 checkbox, shown directly in the page.
/// [onChanged] gets the token when solved, and null when it expires.
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
  late final String _viewType;
  late final web.HTMLDivElement _div;
  JSAny? _widgetId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewType = 'recaptcha-${DateTime.now().microsecondsSinceEpoch}';
    _div = web.document.createElement('div') as web.HTMLDivElement;
    _div.style.width = '304px';
    _div.style.height = '78px';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) => _div);
    _loadAndRender();
  }

  Future<void> _ensureScript() async {
    bool hasRender() {
      if (!globalContext.has('grecaptcha')) return false;
      final g = globalContext.getProperty<JSObject>('grecaptcha'.toJS);
      return g.has('render');
    }

    if (!hasRender()) {
      final loaded = Completer<void>();
      final script =
          web.document.createElement('script') as web.HTMLScriptElement;
      script.src = 'https://www.google.com/recaptcha/api.js?render=explicit';
      script.async = true;
      script.onload = ((web.Event _) {
        if (!loaded.isCompleted) loaded.complete();
      }).toJS;
      script.onerror = ((web.Event _) {
        if (!loaded.isCompleted) {
          loaded.completeError('Could not load reCAPTCHA. Check your connection.');
        }
      }).toJS;
      web.document.head!.appendChild(script);
      await loaded.future;
    }

    final g = globalContext.getProperty<JSObject>('grecaptcha'.toJS);
    final ready = Completer<void>();
    g.callMethod(
      'ready'.toJS,
      (() {
        if (!ready.isCompleted) ready.complete();
      }).toJS,
    );
    await ready.future;
  }

  Future<void> _loadAndRender() async {
    try {
      await _ensureScript();
      // Let Flutter attach the platform view to the page first.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      final g = globalContext.getProperty<JSObject>('grecaptcha'.toJS);
      final params = JSObject()
        ..setProperty('sitekey'.toJS, widget.siteKey.toJS)
        ..setProperty(
          'callback'.toJS,
          ((JSString token) {
            if (mounted) widget.onChanged(token.toDart);
          }).toJS,
        )
        ..setProperty(
          'expired-callback'.toJS,
          (() {
            if (mounted) widget.onChanged(null);
          }).toJS,
        );
      _widgetId = g.callMethod<JSAny?>('render'.toJS, _div, params);
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // Closes the challenge popup if it is still open.
    try {
      if (_widgetId != null && globalContext.has('grecaptcha')) {
        final g = globalContext.getProperty<JSObject>('grecaptcha'.toJS);
        g.callMethod<JSAny?>('reset'.toJS, _widgetId);
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red));
    }
    return SizedBox(
      width: 304,
      height: 78,
      child: Stack(
        children: [
          HtmlElementView(viewType: _viewType),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}