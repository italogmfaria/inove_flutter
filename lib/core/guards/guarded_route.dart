import 'package:flutter/material.dart';
import 'auth_guard.dart';

/// Wrapper que aplica proteção de rota
class GuardedRoute extends StatelessWidget {
  final RouteGuardType guardType;
  final Widget child;

  const GuardedRoute({
    super.key,
    required this.guardType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard.guardRoute(
      guardType: guardType,
      child: child,
      context: context,
    );
  }
}

