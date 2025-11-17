import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/theme_provider.dart';
import '../../core/utils/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../services/school_service.dart';
import '../../services/file_service.dart';
import '../../services/user_progress_service.dart';
import '../../viewmodel/perfil_viewmodel.dart';
import '../../model/course_model.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/edit_profile_modal.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  late PerfilViewModel _viewModel;
  int _selectedIndex = 2; // Perfil é o índice 2

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = UserService(apiService);
    final schoolService = SchoolService(apiService);
    final userProgressService = UserProgressService(apiService);
    _viewModel = PerfilViewModel(userService, schoolService, authService, userProgressService);
    _viewModel.loadProfile(context: context);
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/cursos');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/meus-cursos');
        break;
      case 2:
        // Already on Perfil
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Sair',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair?',
          style: GoogleFonts.inter(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Sair',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _viewModel.logout(context);
    }
  }

  Future<void> _showUnenrollDialog(BuildContext context, CursoModel curso, PerfilViewModel viewModel, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.primaryColor : Colors.white,
        title: Text(
          'Remover inscrição',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textColor,
          ),
        ),
        content: Text(
          'Deseja remover sua inscrição do curso "${curso.name}"?',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? Colors.white.withAlpha(200) : AppColors.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Remover',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.errorColorLight : AppColors.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (curso.id != null) {
        await viewModel.unenrollFromCourse(curso.id!, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.tertiaryColor : AppColors.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            'Perfil',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await themeProvider.toggleTheme();
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: _handleLogout,
            ),
            const SizedBox(width: 3),
          ],
        ),
        body: BackgroundDecoration(
          child: Column(
            children: [
              Expanded(
                child: Consumer<PerfilViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.primaryButton : AppColors.primaryColor,
                          ),
                        ),
                      );
                    }

                    if (viewModel.user == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: isDark
                                    ? AppColors.errorColorLight
                                    : AppColors.errorColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erro ao carregar perfil',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final user = viewModel.user!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.inputColor.withAlpha(60)
                              : AppColors.borderColor.withAlpha(100),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Email: ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.inputColor,
                                ),
                              ),
                              Text(
                                user.email,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.inputColor,
                                ),
                              ),
                            ],
                          ),
                          if (user.cpf.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'CPF: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withAlpha(180)
                                        : AppColors.inputColor,
                                  ),
                                ),
                                Text(
                                  Formatters.formatCpf(user.cpf),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withAlpha(180)
                                        : AppColors.inputColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (viewModel.school != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Escola: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withAlpha(180)
                                        : AppColors.inputColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    viewModel.school!.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withAlpha(180)
                                          : AppColors.inputColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    SecondaryButton(
                      text: 'Editar Perfil',
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => EditProfileModal(
                            initialName: user.name,
                            initialEmail: user.email,
                            initialCpf: user.cpf,
                            initialSchool: viewModel.school,
                            schools: viewModel.schools,
                            isDark: isDark,
                            onSave: (data) async {
                              await viewModel.updateProfile(data, context);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Sair',
                      onPressed: _handleLogout,
                    ),

                    const SizedBox(height: 24),

                    // Courses List
                    if (viewModel.isLoadingCourses)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.primaryButton : AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                    else if (viewModel.myCourses.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meus Cursos',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.inputColor.withAlpha(60)
                                    : AppColors.borderColor.withAlpha(100),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Você ainda não está inscrito em nenhum curso',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.inputColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Em Andamento Section
                          if (viewModel.coursesInProgress.isNotEmpty) ...[
                            Text(
                              'Em Andamento',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: viewModel.coursesInProgress.map((curso) {
                                return _buildCourseCard(context, curso, isDark, viewModel);
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Concluídos Section
                          if (viewModel.completedCourses.isNotEmpty) ...[
                            Text(
                              'Concluídos',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: viewModel.completedCourses.map((curso) {
                                return _buildCourseCard(context, curso, isDark, viewModel);
                              }).toList(),
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onBottomNavTap,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CursoModel curso, bool isDark, PerfilViewModel viewModel) {
    final progress = viewModel.getCourseProgress(curso);
    final progressPercent = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.inputColor.withAlpha(60)
              : AppColors.borderColor.withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pushNamed('/painel-curso', arguments: curso);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Course Icon/Image
                FutureBuilder<String?>(
                  future: curso.id != null
                      ? FileService(Provider.of<ApiService>(context, listen: false)).getCourseImageUrl(curso.id!)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.tertiaryColor
                            : AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? AppColors.primaryButton : AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            : snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty
                                ? Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: isDark
                                              ? AppColors.primaryButton
                                              : AppColors.primaryColor,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: isDark
                                          ? AppColors.primaryButton
                                          : AppColors.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curso.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progresso',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.inputColor,
                                ),
                              ),
                              if (viewModel.isLoadingProgress)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? AppColors.primaryButton : AppColors.primaryButton,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '$progressPercent%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.primaryButton
                                        : AppColors.primaryButton,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: isDark
                                  ? AppColors.tertiaryColor
                                  : AppColors.borderColor.withAlpha(50),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.primaryButton : AppColors.primaryButton,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Botão de remover inscrição
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.errorColorLight : AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => _showUnenrollDialog(context, curso, viewModel, isDark),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    tooltip: 'Remover inscrição do curso',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
