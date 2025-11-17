import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../services/file_service.dart';
import '../../services/user_progress_service.dart';
import '../../viewmodel/meus_cursos_viewmodel.dart';
import '../../model/course_model.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/custom_bottom_nav.dart';

class MeusCursosView extends StatefulWidget {
  const MeusCursosView({super.key});

  @override
  State<MeusCursosView> createState() => _MeusCursosViewState();
}

class _MeusCursosViewState extends State<MeusCursosView> {
  late MeusCursosViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // Meus Cursos é o índice 1

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    final userService = UserService(apiService);
    final userProgressService = UserProgressService(apiService);
    _viewModel = MeusCursosViewModel(userService, userProgressService);
    _viewModel.loadMeusCursos(context: context);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/inicial',
          (route) => false,
        );
      }
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _viewModel.navigateToAllCursos(context);
        break;
      case 1:
        // Already on Meus Cursos
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/perfil');
        break;
    }
  }

  List<CursoModel> get _filteredCursos {
    if (_searchController.text.isEmpty) {
      return _viewModel.meusCursos;
    }

    final query = _searchController.text.toLowerCase();
    return _viewModel.meusCursos.where((curso) {
      return curso.name.toLowerCase().contains(query) ||
          curso.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context, listen: false);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.tertiaryColor : AppColors.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            'Meus Cursos',
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
            const SizedBox(width: 3),
            FutureBuilder<bool>(
              future: authService.isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return IconButton(
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: _handleLogout,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BackgroundDecoration(
          child: Column(
            children: [
              // Search Bar
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  cursorColor: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white.withAlpha(200) : AppColors.inputColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar meus cursos...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark
                          ? Colors.white.withAlpha(130)
                          : AppColors.inputColor.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? Colors.white.withAlpha(200)
                          : AppColors.inputColor,
                      size: 24,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.primaryColor : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(200)
                            : AppColors.inputColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(200)
                            : AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(200)
                            : AppColors.inputColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Courses List
              Expanded(
                child: Consumer<MeusCursosViewModel>(
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

                    if (viewModel.errorMessage != null) {
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
                                viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  viewModel.loadMeusCursos(context: context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.primaryButton
                                      : AppColors.primaryColor,
                                ),
                                child: Text(
                                  'Tentar novamente',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final filteredCursos = _filteredCursos;

                    if (filteredCursos.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: isDark
                                    ? Colors.white.withAlpha(130)
                                    : AppColors.inputColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'Você ainda não está inscrito em nenhum curso'
                                    : 'Nenhum curso encontrado',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.inputColor,
                                ),
                              ),
                              if (_searchController.text.isEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.navigateToAllCursos(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.primaryButton
                                        : AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    'Ver cursos disponíveis',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredCursos.length,
                      itemBuilder: (context, index) {
                        final curso = filteredCursos[index];
                        return _buildCourseCard(context, curso, isDark, viewModel);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FutureBuilder<bool>(
          future: authService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return CustomBottomNav(
                selectedIndex: _selectedIndex,
                onTap: _onBottomNavTap,
                isDark: isDark,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CursoModel curso, bool isDark, MeusCursosViewModel viewModel) {
    final progress = viewModel.getCourseProgress(curso);
    final progressPercent = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            viewModel.navigateToCursoPainel(context, curso);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Icon/Image
                    FutureBuilder<String?>(
                      future: curso.id != null
                          ? FileService(Provider.of<ApiService>(context, listen: false)).getCourseImageUrl(curso.id!)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        return Container(
                          width: 80,
                          height: 80,
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
                                      width: 24,
                                      height: 24,
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
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  isDark ? AppColors.primaryButton : AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              color: isDark
                                                  ? AppColors.primaryButton
                                                  : AppColors.primaryColor,
                                              size: 40,
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
                                          size: 40,
                                        ),
                                      ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),

                    // Course Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            curso.description,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withAlpha(200)
                                  : AppColors.inputColor,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Progress Bar
                const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
