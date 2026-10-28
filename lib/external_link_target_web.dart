import 'dart:js_interop';

import 'package:flutter/widgets.dart';

@JS()
extension type _AnchorElement(JSObject _) implements JSObject {
  external void setAttribute(String name, String value);
}

Widget buildBrowserLink(String url, String label) =>
    HtmlElementView.fromTagName(
      tagName: 'a',
      onElementCreated: (element) {
        final anchor = _AnchorElement(element as JSObject);
        anchor.setAttribute('href', url);
        anchor.setAttribute('target', '_blank');
        anchor.setAttribute('rel', 'noopener noreferrer');
        anchor.setAttribute('aria-label', label);
        anchor.setAttribute('class', 'yro-external-link');
        anchor.setAttribute(
          'style',
          'display:block;width:100%;height:100%;box-sizing:border-box;border-radius:6px;',
        );
      },
    );
