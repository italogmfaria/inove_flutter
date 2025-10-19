import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/dev_placeholder.dart';
import '../../widgets/background_decoration.dart';

class RedefinirSenhaView extends StatefulWidget {
  const RedefinirSenhaView({super.key});

  @override
  State<RedefinirSenhaView> createState() => _RedefinirSenhaViewState();
}

class _RedefinirSenhaViewState extends State<RedefinirSenhaView> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implementar view
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Redefinir Senha',
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
