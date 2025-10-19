import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/dev_placeholder.dart';
import '../../widgets/background_decoration.dart';

class PainelCursoView extends StatefulWidget {
  const PainelCursoView({super.key});

  @override
  State<PainelCursoView> createState() => _PainelCursoViewState();
}

class _PainelCursoViewState extends State<PainelCursoView> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implementar view
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nome do Curso',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: const BackgroundDecoration(
        child: DevPlaceholder(),
      ),
    );
  }
}
