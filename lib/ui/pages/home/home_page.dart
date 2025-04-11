import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app_settings.dart';
import 'controls/headphones_controls_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings),
            tooltip: l.settings,
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de bienvenida
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Text(
                  l.headphonesControl,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutQuad)
                  .slideX(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

              // Widget principal con los controles
              Expanded(
                child: HeadphonesControlsWidget(
                  headphones: context.read<AppSettings>().currentHeadphones,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
      // Botón flotante para ir rápidamente a la configuración de los auriculares
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/headphones_settings'),
        tooltip: l.pageHeadphonesSettingsTitle,
        elevation: 4,
        child: const Icon(Symbols.settings),
      ).animate(controller: _controller).scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: 400.ms,
          curve: Curves.elasticOut),
    );
  }
}
