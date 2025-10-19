import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/dev_placeholder.dart';
import '../../widgets/background_decoration.dart';

class CadastroEscolaView extends StatefulWidget {
  const CadastroEscolaView({super.key});

  @override
  State<CadastroEscolaView> createState() => _CadastroEscolaViewState();
}

class _CadastroEscolaViewState extends State<CadastroEscolaView> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implementar view
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro Escola',
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
