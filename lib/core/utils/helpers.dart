import 'package:flutter/material.dart';

class Helpers {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = Colors.red;
      icon = Icons.error;
    } else if (isWarning) {
      backgroundColor = Colors.orange;
      icon = Icons.warning;
    } else {
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message, {String? title}) {
    showSnackBar(context, title != null ? '$title: $message' : message);
  }

  static void showError(BuildContext context, String message, {String? title}) {
    showSnackBar(context, title != null ? '$title: $message' : message, isError: true);
  }

  static void showWarning(BuildContext context, String message, {String? title}) {
    showSnackBar(context, title != null ? '$title: $message' : message, isWarning: true);
  }

  static void showInfo(BuildContext context, String message, {String? title}) {
    showSnackBar(context, title != null ? '$title: $message' : message);
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static void markAllFieldsTouched(GlobalKey<FormState> formKey) {
    final form = formKey.currentState;
    if (form != null) {
      form.validate();
    }
  }

  static void validateAndNavigate(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String route, {
    Object? arguments,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    }
  }

  static void navigateTo(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  static void navigateAndReplace(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  static bool isFieldInvalid(GlobalKey<FormState> formKey, String fieldName) {
    return false;
  }
}
