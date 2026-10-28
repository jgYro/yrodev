import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'external_link_target_stub.dart'
    if (dart.library.js_interop) 'external_link_target_web.dart'
    as target;

class ExternalLink extends StatelessWidget {
  const ExternalLink({
    super.key,
    required this.url,
    required this.label,
    required this.child,
  });

  final String url;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final browserLink = target.buildBrowserLink(url, label);
    if (browserLink != null) {
      return Stack(
        children: [
          ExcludeSemantics(child: child),
          Positioned.fill(child: browserLink),
        ],
      );
    }

    Future<void> copyAddress() async {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Website address copied: $url')));
      }
    }

    return Semantics(
      button: true,
      label: 'Copy website address: $url',
      onTap: copyAddress,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: copyAddress,
          borderRadius: BorderRadius.circular(6),
          child: child,
        ),
      ),
    );
  }
}
