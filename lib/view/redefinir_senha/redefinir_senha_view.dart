import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/redefinir_senha_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/primary_button.dart';

class RedefinirSenhaView extends StatefulWidget {
  const RedefinirSenhaView({super.key});

  @override
  State<RedefinirSenhaView> createState() => _RedefinirSenhaViewState();
}

class _RedefinirSenhaViewState extends State<RedefinirSenhaView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _email;
  String? _code;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String?;
    _code = args?['code'] as String?;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RedefinirSenhaViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Redefinir senha',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
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
                              'Crie uma nova senha segura para sua conta.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Nova senha Input
                            Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return CustomInput(
                                  controller: _passwordController,
                                  label: 'Nova senha',
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: viewModel.obscurePassword,
                                  validator: viewModel.validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white.withAlpha(200)
                                          : AppColors.inputColor,
                                    ),
                                    onPressed: viewModel.togglePasswordVisibility,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Confirmar nova senha Input
                            Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return CustomInput(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar nova senha',
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: viewModel.obscureConfirmPassword,
                                  validator: (value) => viewModel.validateConfirmPassword(
                                    _passwordController.text,
                                    value,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white.withAlpha(200)
                                          : AppColors.inputColor,
                                    ),
                                    onPressed: viewModel.toggleConfirmPasswordVisibility,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Botão Redefinir senha
                            PrimaryButton(
                              text: 'Redefinir senha',
                              isLoading: viewModel.isLoading,
                              onPressed: () {
                                if (_email == null || _code == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dados de verificação inválidos'),
                                    ),
                                  );
                                  return;
                                }

                                if (_formKey.currentState?.validate() ?? false) {
                                  viewModel.resetPassword(
                                    _email!,
                                    _code!,
                                    _passwordController.text,
                                    _confirmPasswordController.text,
                                    context,
                                  ).then((success) {
                                    if (success && mounted) {
                                      viewModel.navigateToLogin(context);
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
