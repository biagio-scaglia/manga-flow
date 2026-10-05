import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';

/// Logo editoriale per MangaFlow.
///
/// Disegnato come un sigillo editoriale giapponese (Hanko/Stamp)
/// che si integra armoniosamente sia nel tema scuro (Night Ink)
/// che nel tema chiaro (Washi Paper) senza riquadri bianchi stonati.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showSpine;

  const AppLogo({
    super.key,
    this.size = 28,
    this.showSpine = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.editorialRed,
        borderRadius: AppRadii.brXs,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sfumatura costina libro a sinistra
          if (showSpine)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: size * 0.18,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(3),
                  ),
                  color: Colors.black.withValues(alpha: 0.22),
                ),
              ),
            ),

          // Monogramma MF con stile editoriale Space Grotesk
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: showSpine ? size * 0.08 : 0),
              child: Text(
                'MF',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
