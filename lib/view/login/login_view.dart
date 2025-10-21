import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/login_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/primary_button.dart';
import '../../core/theme/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
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

                            // E-mail Input
                            Builder(
                              builder: (context) {
                                return CustomInput(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  hint: 'seu@email.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: viewModel.validateEmail,
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Input
                            Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return CustomInput(
                                  controller: _passwordController,
                                  label: 'Senha',
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

                            const SizedBox(height: 16),

                            // Forgot Password Link
                            Center(
                              child: TextButton(
                                onPressed: () => viewModel.navigateToForgotPassword(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Esqueceu sua senha? '),
                                      TextSpan(
                                        text: 'Recupere aqui!',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Login Button
                            PrimaryButton(
                              text: 'Entrar',
                              isLoading: viewModel.isLoading,
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  final success = await viewModel.login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                    context,
                                  );

                                  if (success && context.mounted) {
                                    Navigator.of(context).pushReplacementNamed('/meus-cursos');
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // Register Link
                            Center(
                              child: TextButton(
                                onPressed: () => viewModel.navigateToRegister(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Não tem acesso? '),
                                      TextSpan(
                                        text: 'Clique aqui!',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
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
