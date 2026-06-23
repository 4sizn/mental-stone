import 'package:flutter/material.dart';

/// Screen 06 — My Stone Records.
///
/// Intentionally blank — a clean canvas pending a full redesign. The bottom
/// nav is owned by [MainShell], so this screen only renders its (empty) body.
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key, this.showBottomNav = true});

  /// Kept for API compatibility with [MainShell]; the shell owns the nav.
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}
