import 'dart:js_interop';

@JS('window.location.assign')
external void _navigate(JSString url);

bool openMailto(String url) {
  _navigate(url.toJS);
  return true;
}
