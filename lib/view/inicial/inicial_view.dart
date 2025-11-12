import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/inicial_viewmodel.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/primary_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/theme_provider.dart';

class InicialView extends StatelessWidget {
  const InicialView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InicialViewModel(),
      child: const InicialViewContent(),
    );
  }
}

class InicialViewContent extends StatelessWidget {
  const InicialViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InicialViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo scrollável
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.25,
                    vertical: screenHeight * 0,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.01),

                      Image.asset(
                        'assets/logo.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: screenHeight * 0),

                      const Text(
                        'Melhore seu conhecimento\ncom a tecnologia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      PrimaryButton(
                        text: 'Login',
                        onPressed: () => viewModel.navigateToLogin(context),
                      ),

                      const SizedBox(height: 20),

                      PrimaryButton(
                        text: 'Ver cursos',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/cursos');
                        },
                      ),

                      SizedBox(height: screenHeight * 0.07),
                    ],
                  ),
                ),

                BackgroundDecoration(
                  showDecoration: true,
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.menu_book_outlined,
                          iconColor: AppColors.primaryColor,
                          title: 'Plataforma Gratuita',
                          description: 'Aprenda sem custo.',
                        ),

                        const SizedBox(height: 16),

                        _buildFeatureCard(
                          icon: Icons.school_outlined,
                          iconColor: AppColors.primaryColor,
                          title: 'Apoio ao Conhecimento',
                          description: 'Conteúdos práticos.',
                        ),

                        const SizedBox(height: 16),

                        _buildFeatureCard(
                          icon: Icons.lightbulb_outline,
                          iconColor: AppColors.primaryColor,
                          title: 'Melhor Aprendizado',
                          description: 'Metodologias ativas.',
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color ?? (isDark ? AppColors.primaryColor : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.inputColor.withAlpha(80)
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.tertiaryColor
                                              : AppColors.secondaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.info_outline,
                                          color: isDark ? AppColors.primaryButton : AppColors.primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Sobre o projeto',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    'O INOVE é uma plataforma educacional gratuita que tem como objetivo democratizar o acesso ao conhecimento tecnológico. Através de cursos práticos e metodologias ativas, buscamos apoiar professores e alunos no desenvolvimento de competências digitais essenciais para o mundo moderno.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withAlpha(220)
                                          : AppColors.inputColor,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botão fixo no canto superior direito
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? (isDark ? AppColors.primaryColor : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.inputColor.withAlpha(80)
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.tertiaryColor
                      : AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.primaryButton : iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withAlpha(220)
                            : AppColors.inputColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
