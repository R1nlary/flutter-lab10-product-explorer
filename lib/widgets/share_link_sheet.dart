import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';

Future<void> showShareLinkSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => ShareLinkSheet(link: product.deepLink),
  );
}

class ShareLinkSheet extends StatefulWidget {
  const ShareLinkSheet({super.key, required this.link});

  final String link;

  @override
  State<ShareLinkSheet> createState() => _ShareLinkSheetState();
}

class _ShareLinkSheetState extends State<ShareLinkSheet> {
  bool _copied = false;

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.link));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Share this product', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(widget.link),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _copyLink,
              icon: Icon(_copied ? Icons.check : Icons.copy),
              label: Text(_copied ? 'Copied' : 'Copy Link'),
            ),
          ],
        ),
      ),
    );
  }
}
