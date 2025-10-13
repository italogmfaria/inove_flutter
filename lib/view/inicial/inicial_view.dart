import 'package:flutter/material.dart';
import 'package:inove_flutter/widgets/dev_placeholder.dart';
import 'package:inove_flutter/widgets/secondary-button.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class InicialView extends StatefulWidget {
  const InicialView({super.key});

  @override
  State<InicialView> createState() => _InicialViewState();
}

class _InicialViewState extends State<InicialView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Image.asset(
                'assets/logo.png',
                height: 120,
              ),

              const SizedBox(height: 60),

              PrimaryButton(
                text: 'Entrar',
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),

              const SizedBox(height: 16),

              SecondaryButton(
                text: 'Ver Cursos',
                onPressed: () {
                  Navigator.pushNamed(context, '/cursos');
                },
              ),

              const SizedBox(height: 50),

              DevPlaceholder(),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
