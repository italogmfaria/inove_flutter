import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/dev_placeholder.dart';
import '../../widgets/background_decoration.dart';

class VerificarCodigoView extends StatefulWidget {
  const VerificarCodigoView({super.key});

  @override
  State<VerificarCodigoView> createState() => _VerificarCodigoViewState();
}

class _VerificarCodigoViewState extends State<VerificarCodigoView> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implementar view
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verificar Código',
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
