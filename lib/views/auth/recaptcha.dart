// Picks the right implementation per platform.
// Usage stays the same everywhere: showRecaptcha(context, siteKey: '...')
export 'recaptcha_mobile.dart'
    if (dart.library.js_interop) 'recaptcha_web.dart';