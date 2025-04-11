import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../pages/home/no_permission_info_widget.dart';

class FreebuddyIntroduction extends StatelessWidget {
  const FreebuddyIntroduction({super.key});

  // I wanted to add "copy on long press" here, but recognizer can detect only
  // one :sob:
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
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;

    newline() => const TextSpan(text: "\n");

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 6),
              Text(l.pageIntroTitle, style: tt.displayMedium, textAlign: TextAlign.center),
              const Spacer(flex: 12),
              // Rich text with introduction and link to privacy policy
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: l.pageIntroWhatIsThis),
                    newline(),
                    newline(),
                    TextSpan(text: l.pageIntroSupported),
                    newline(),
                    newline(),
                    TextSpan(text: l.pageIntroShortPrivacyPolicy),
                    _link(l.privacyPolicy, l.privacyPolicyUrl),
                    WidgetSpan(
                      child: Icon(
                        Icons.open_in_new,
                        size: tt.bodyMedium!.fontSize,
                        color: Colors.blue,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    newline(),
                    newline(),
                    TextSpan(text: l.pageIntroAnyQuestions),
                  ],
                  style: tt.bodyMedium,
                ),
              ),
              const Spacer(flex: 10),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Marcar la introducción como vista
                      GoRouter.of(context).pop<bool>(true);
                      // Mostrar la pantalla de permisos después de cerrar la introducción
                      _showPermissionsScreen(context);
                    },
                    child: Text(l.pageIntroQuit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para mostrar la pantalla de permisos
  void _showPermissionsScreen(BuildContext context) {
    // Usar Navigator para mostrar un diálogo modal con los permisos
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el diálogo haciendo clic fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.pageHomeNoPermission),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Usar el widget mejorado de permisos
                const NoPermissionInfoWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
