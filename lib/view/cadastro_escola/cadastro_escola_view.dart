import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/cadastro_escola_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/primary_button.dart';

class CadastroEscolaView extends StatefulWidget {
  const CadastroEscolaView({super.key});

  @override
  State<CadastroEscolaView> createState() => _CadastroEscolaViewState();
}

class _CadastroEscolaViewState extends State<CadastroEscolaView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CadastroEscolaViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cadastro de Escola'),
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

                            // Nome da Escola
                            CustomInput(
                              controller: _nameController,
                              label: 'Nome da Escola',
                              hint: 'Nome completo da escola',
                              prefixIcon: Icons.business_outlined,
                              validator: viewModel.validateName,
                            ),

                            const SizedBox(height: 20),

                            // E-mail
                            CustomInput(
                              controller: _emailController,
                              label: 'E-mail',
                              hint: 'contato@escola.edu.br',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: viewModel.validateEmail,
                            ),

                            const SizedBox(height: 20),

                            // Cidade
                            CustomInput(
                              controller: _cityController,
                              label: 'Cidade',
                              hint: 'Nome da cidade',
                              prefixIcon: Icons.location_city_outlined,
                              validator: viewModel.validateCity,
                            ),

                            const SizedBox(height: 20),

                            // Estado
                            CustomInput(
                              controller: _stateController,
                              label: 'Estado',
                              hint: 'UF',
                              prefixIcon: Icons.map_outlined,
                              validator: viewModel.validateState,
                              maxLength: 2,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Botão Cadastrar
                            if (viewModel.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              PrimaryButton(
                                text: 'Cadastrar',
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    final success = await viewModel.registerSchool(
                                      nome: _nameController.text,
                                      cidade: _cityController.text,
                                      email: _emailController.text,
                                      federativeUnit: _stateController.text.toUpperCase(),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.toUpperCase();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
