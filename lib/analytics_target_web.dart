import 'dart:js_interop';

@JS('window.yroAnalytics.available')
external JSBoolean _available();
@JS('window.yroAnalytics.consent')
external JSString _consent();
@JS('window.yroAnalytics.setConsent')
external void _setConsent(JSBoolean granted);
@JS('window.yroAnalytics.track')
external JSBoolean _track(JSString event, JSString parameters);

bool available() {
  try {
    return _available().toDart;
  } catch (_) {
    return false;
  }
}

String consent() {
  try {
    return _consent().toDart;
  } catch (_) {
    return 'unknown';
  }
}

void setConsent(bool granted) {
  try {
    _setConsent(granted.toJS);
  } catch (_) {
    // Consent UI and core site actions must survive a blocked script.
  }
}

bool track(String event, String parameters) {
  try {
    return _track(event.toJS, parameters.toJS).toDart;
  } catch (_) {
    return false;
  }
}
