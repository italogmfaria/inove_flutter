import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../model/school_model.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'custom_input.dart';
import 'custom_dropdown.dart';

class EditProfileModal extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialCpf;
  final SchoolModel? initialSchool;
  final List<SchoolModel> schools;
  final Function(Map<String, dynamic>) onSave;
  final bool isDark;

  const EditProfileModal({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialCpf,
    this.initialSchool,
    required this.schools,
    required this.onSave,
    required this.isDark,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  SchoolModel? _selectedSchool;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _cpfController = TextEditingController(text: Formatters.formatCpf(widget.initialCpf));

    // Buscar a escola na lista pelo ID para garantir que é a mesma instância
    if (widget.initialSchool != null && widget.initialSchool!.id != null && widget.schools.isNotEmpty) {
      try {
        _selectedSchool = widget.schools.firstWhere(
          (school) => school.id == widget.initialSchool!.id,
        );
      } catch (e) {
        // Se não encontrar na lista, deixa null
        _selectedSchool = null;
      }
    } else {
      _selectedSchool = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    // Validar o formulário antes de salvar
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = <String, dynamic>{};

      if (_nameController.text.trim() != widget.initialName) {
        data['name'] = _nameController.text.trim();
      }

      if (_emailController.text.trim() != widget.initialEmail) {
        data['email'] = _emailController.text.trim();
      }

      // Limpar formatação do CPF antes de enviar
      final cleanedCpf = Formatters.cleanCpf(_cpfController.text);
      if (cleanedCpf != widget.initialCpf) {
        data['cpf'] = cleanedCpf;
      }

      // Verificar se a escola foi alterada
      if (_selectedSchool?.id != widget.initialSchool?.id) {
        if (_selectedSchool != null && _selectedSchool!.id != null) {
          // Enviar escola como objeto com id, igual ao Angular
          data['school'] = {
            'id': _selectedSchool!.id
          };
        } else {
          data['school'] = null;
        }
      }

      if (data.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      await widget.onSave(data);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(widget.isDark ? 60 : 20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar dados',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : AppColors.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.isDark ? Colors.white : AppColors.textColor,
                  ),
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form with validation
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Nome completo field
                  CustomInput(
                    controller: _nameController,
                    label: 'Nome completo',
                    prefixIcon: Icons.person_outline,
                    enabled: !_isLoading,
                    validator: (value) => Validators.required(value, fieldName: 'Nome'),
                  ),
                  const SizedBox(height: 16),

                  // E-mail field
                  CustomInput(
                    controller: _emailController,
                    label: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // CPF field
                  CustomInput(
                    controller: _cpfController,
                    label: 'CPF',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [Formatters.cpf()],
                    enabled: !_isLoading,
                    validator: Validators.cpf,
                  ),
                  const SizedBox(height: 16),

                  // Escola dropdown
                  CustomDropdown<SchoolModel>(
                    value: _selectedSchool,
                    label: 'Escola',
                    hint: 'Selecione sua escola',
                    prefixIcon: Icons.school_outlined,
                    enabled: !_isLoading,
                    items: widget.schools.map((school) => DropdownMenuItem(
                      value: school,
                      child: Text(
                        school.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: widget.isDark
                              ? Colors.white
                              : AppColors.textColor,
                        ),
                      ),
                    )).toList(),
                    onChanged: _isLoading ? null : (school) {
                      setState(() => _selectedSchool = school);
                    },
                    validator: (value) => Validators.required(value?.name, fieldName: 'Escola'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Salvar button
            PrimaryButton(
              text: 'Salvar',
              onPressed: _handleSave,
              isLoading: _isLoading,
              height: 48,
            ),
            const SizedBox(height: 12),

            // Cancelar button
            SecondaryButton(
              text: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

