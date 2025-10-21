import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../model/school_model.dart';
import '../../viewmodel/cadastro_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/primary_button.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  SchoolModel? _selectedSchool;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CadastroViewModel>().loadSchools(context);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CadastroViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cadastro'),
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

                            // Nome completo
                            CustomInput(
                              controller: _nameController,
                              label: 'Nome completo',
                              hint: 'Seu nome completo',
                              prefixIcon: Icons.person_outline,
                              validator: viewModel.validateName,
                            ),

                            const SizedBox(height: 20),

                            // E-mail
                            CustomInput(
                              controller: _emailController,
                              label: 'E-mail',
                              hint: 'seu@email.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: viewModel.validateEmail,
                            ),

                            const SizedBox(height: 20),

                            // CPF
                            CustomInput(
                              controller: _cpfController,
                              label: 'CPF',
                              hint: '000.000.000-00',
                              prefixIcon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [Formatters.cpf()],
                              validator: viewModel.validateCpf,
                            ),

                            const SizedBox(height: 20),

                            // Senha
                            Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return CustomInput(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  hint: '••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !viewModel.obscurePassword,
                                  validator: viewModel.validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      !viewModel.obscurePassword
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

                            // Escola
                            CustomDropdown<SchoolModel>(
                              value: _selectedSchool,
                              label: 'Escola',
                              hint: 'Selecione sua escola',
                              prefixIcon: Icons.school_outlined,
                              items: viewModel.schools.map((school) => DropdownMenuItem(
                                value: school,
                                child: Text(
                                  school.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : AppColors.textColor,
                                  ),
                                ),
                              )).toList(),
                              onChanged: (school) {
                                setState(() => _selectedSchool = school);
                              },
                              validator: (value) => Validators.required(value?.name, fieldName: 'Escola'),
                            ),

                            const SizedBox(height: 24),

                            // Link para cadastro de escola
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/cadastro-escola');
                                },
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
                                      const TextSpan(text: 'Não encontrou sua escola? '),
                                      TextSpan(
                                        text: 'Cadastre aqui!',
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

                            const SizedBox(height: 24),

                            // Botão Cadastrar
                            if (viewModel.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              PrimaryButton(
                                text: 'Cadastrar',
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    if (_selectedSchool == null) {
                                      Helpers.showError(context, 'Selecione uma escola');
                                      return;
                                    }

                                    final success = await viewModel.register(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      cpf: _cpfController.text,
                                      password: _passwordController.text,
                                      confirmPassword: _passwordController.text,
                                      birthDate: DateTime.now(),
                                      school: _selectedSchool!,
                                      context: context,
                                    );

                                    if (success && mounted) {
                                      Navigator.of(context).pop();
                                    }
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
