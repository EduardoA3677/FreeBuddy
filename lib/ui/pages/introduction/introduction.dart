import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/dimensions.dart';

class FreebuddyIntroduction extends StatelessWidget {
  const FreebuddyIntroduction({super.key});

  // Para abrir enlaces externos
  TextSpan _link(String text, [String? url]) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () => launchUrlString(url ?? text, mode: LaunchMode.externalApplication),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 360;

    newline() => const TextSpan(text: "\n");

    return Scaffold(
      body: Container(
        // Fondo con gradiente moderno
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.all(AppDimensions.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Logo y título con animación
                  Container(
                    padding: EdgeInsets.all(AppDimensions.spacing24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.headphones,
                          size: AppDimensions.iconXLarge + 24,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: AppDimensions.spacing16),
                        Text(
                          l.pageIntroTitle,
                          style: tt.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOutBack),

                  const Spacer(flex: 6),

                  // Tarjeta con información principal
                  Card(
                    elevation: AppDimensions.elevationSmall,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacing24),
                      child: Column(
                        children: [
                          // Título de la sección
                          Text(
                            '¡Bienvenido a FreeBuddy!',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppDimensions.spacing16),

                          // Contenido principal con mejor formato
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: l.pageIntroWhatIsThis,
                                  style: tt.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                                newline(),
                                newline(),
                                TextSpan(
                                  text: l.pageIntroSupported,
                                  style: tt.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                                newline(),
                                newline(),
                                TextSpan(
                                  text: l.pageIntroShortPrivacyPolicy,
                                  style: tt.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                                _link(l.privacyPolicy, l.privacyPolicyUrl),
                                WidgetSpan(
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: tt.bodyMedium!.fontSize,
                                    color: theme.colorScheme.primary,
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                newline(),
                                newline(),
                                TextSpan(
                                  text: l.pageIntroAnyQuestions,
                                  style: tt.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 300.ms),

                  const Spacer(flex: 4),

                  // Botón para comenzar con estilo moderno
                  FilledButton.icon(
                    onPressed: () {
                      // Marcar la introducción como vista y regresar a la página principal
                      GoRouter.of(context).pop<bool>(true);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      l.pageIntroQuit,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallDevice ? 24 : 32,
                        vertical: isSmallDevice ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      delay: 600.ms),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
