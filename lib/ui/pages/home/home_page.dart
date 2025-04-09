import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app_settings.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';
import 'controls/headphones_controls_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(_introCheck);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _introCheck() async {
    final ctx = context;
    final settings = ctx.read<AppSettings>();
    if (!(await settings.seenIntroduction.first)) {
      if (!ctx.mounted) return;
      final success = await GoRouter.of(ctx).push('/introduction') as bool?;
      if (success ?? false) {
        await settings.setSeenIntroduction(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.settings,
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              )),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return isLandscape
                      ? _buildLandscapeLayout(constraints)
                      : _buildPortraitLayout(constraints);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            HeadphonesConnectionEnsuringOverlay(
              builder: (context, headphones) => HeadphonesControlsWidget(headphones: headphones),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HeadphonesConnectionEnsuringOverlay(
              builder: (context, headphones) => HeadphonesControlsWidget(headphones: headphones),
            ),
          ),
        ),
      ],
    );
  }
}
