import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../viewmodel/verificar_codigo_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/primary_button.dart';

class VerificarCodigoView extends StatefulWidget {
  const VerificarCodigoView({super.key});

  @override
  State<VerificarCodigoView> createState() => _VerificarCodigoViewState();
}

class _VerificarCodigoViewState extends State<VerificarCodigoView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String?;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificarCodigoViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Verificar código',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => viewModel.navigateBack(context),
            ),
          ),
          body: BackgroundDecoration(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryColor.withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Center(
                              child: Image.asset(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'assets/logo.png'
                                    : 'assets/logo_colored.png',
                                width: 200,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Texto explicativo
                            Text(
                              'Digite o código de 6 dígitos que foi enviado para seu e-mail.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Código Input
                            CustomInput(
                              controller: _codeController,
                              label: 'Código de verificação',
                              hint: '000000',
                              prefixIcon: Icons.key_outlined,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              validator: viewModel.validateCode,
                            ),

                            const SizedBox(height: 32),

                            // Botão Verificar código
                            PrimaryButton(
                              text: 'Verificar código',
                              isLoading: viewModel.isLoading,
                              onPressed: () {
                                if (_email == null) {
                                  Helpers.showError(context, 'Email não fornecido');
                                  return;
                                }

                                if (_formKey.currentState?.validate() ?? false) {
                                  final code = _codeController.text.trim();
                                  viewModel.verifyCode(
                                    _email!,
                                    code,
                                    context,
                                  ).then((success) {
                                    if (success && mounted) {
                                      viewModel.navigateToResetPassword(
                                        context,
                                        _email!,
                                        code,
                                      );
                                    }
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // Reenviar código Link
                            Center(
                              child: TextButton(
                                onPressed: _email == null || viewModel.isLoading
                                    ? null
                                    : () async {
                                        final success = await viewModel.resendCode(_email!, context);
                                        if (success && mounted) {
                                          _codeController.clear();
                                        }
                                      },
                                child: Text(
                                  'Reenviar código',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 200)
                                        : AppColors.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
