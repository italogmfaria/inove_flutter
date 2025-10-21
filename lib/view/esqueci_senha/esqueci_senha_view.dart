import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/esqueci_senha_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/primary_button.dart';

class EsqueciSenhaView extends StatefulWidget {
  const EsqueciSenhaView({super.key});

  @override
  State<EsqueciSenhaView> createState() => _EsqueciSenhaViewState();
}

class _EsqueciSenhaViewState extends State<EsqueciSenhaView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EsqueciSenhaViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Esqueci minha senha',
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
                              'Digite seu e-mail cadastrado e enviaremos um código de verificação para redefinir sua senha.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // E-mail Input
                            CustomInput(
                              controller: _emailController,
                              label: 'E-mail',
                              hint: 'seu@email.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: viewModel.validateEmail,
                            ),

                            const SizedBox(height: 32),

                            // Botão Enviar código
                            PrimaryButton(
                              text: 'Enviar código',
                              isLoading: viewModel.isLoading,
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  final email = _emailController.text.trim();
                                  viewModel.sendRecoveryEmail(
                                    email,
                                    context,
                                  ).then((success) {
                                    if (success && mounted) {
                                      viewModel.navigateToVerifyCode(context, email);
                                    }
                                  });
                                }
                              },
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
