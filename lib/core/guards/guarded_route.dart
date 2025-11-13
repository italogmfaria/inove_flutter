import 'package:flutter/material.dart';
import 'auth_guard.dart';

class GuardedRoute extends StatefulWidget {
  final RouteGuardType guardType;
  final Widget child;

  const GuardedRoute({
    super.key,
    required this.guardType,
    required this.child,
  });

  @override
  State<GuardedRoute> createState() => _GuardedRouteState();
}

class _GuardedRouteState extends State<GuardedRoute> {
  String? _redirectRoute;
  bool _isChecking = true;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_hasChecked) return;

    final redirectRoute = await AuthGuard.getRedirectRoute(widget.guardType);

    if (mounted) {
      setState(() {
        _redirectRoute = redirectRoute;
        _isChecking = false;
        _hasChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(_redirectRoute!);
        }
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}

