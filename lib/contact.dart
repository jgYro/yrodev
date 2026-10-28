import 'package:flutter/services.dart';

import 'contact_target_stub.dart'
    if (dart.library.js_interop) 'contact_target_web.dart'
    as target;

const businessEmail = 'business@yro.dev';

/// Opens an email draft on the web, or copies the address on native platforms.
Future<bool> openBusinessEmail() async {
  if (target.openMailto('mailto:$businessEmail')) return true;
  await Clipboard.setData(const ClipboardData(text: businessEmail));
  return false;
}
