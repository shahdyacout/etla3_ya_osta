import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/app_router.dart';
import '../../core/entities/user_role_entity.dart';

class NavigationStateService {
  static const _keyLastRoute = 'last_route';
  static const _keyRouteArgs = 'route_args';

  static const _saveableRoutes = [
    AppRouter.destinations,
    AppRouter.trips,
    AppRouter.booking,
    AppRouter.qr,
    AppRouter.liveDirections,
    AppRouter.wallet,
    AppRouter.transactions,
    AppRouter.payment,
    AppRouter.notifications,
    AppRouter.driverHome,
    AppRouter.passengerLoading,
    AppRouter.tripInProgress,
    AppRouter.tripSummary,
    AppRouter.driverWallet,
  ];

  // Routes whose arguments are complex in-memory objects (entities) that
  // cannot be reconstructed from persisted JSON. These are never restored.
  static const _routesWithComplexArgs = [
    AppRouter.booking,
    AppRouter.qr,
  ];

  // Routes that require non-null arguments in AppRouter.generateRoute.
  // They can only be restored when their saved args are present and valid.
  static const _routesRequiringArgs = [
    AppRouter.trips,
    AppRouter.payment,
  ];

  Future<void> saveRoute(String route, [Map<String, dynamic>? args]) async {
    if (!_saveableRoutes.contains(route)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRoute, route);
    if (args != null) {
      await prefs.setString(_keyRouteArgs, jsonEncode(args));
    } else {
      await prefs.remove(_keyRouteArgs);
    }
  }

  Future<({String? route, Map<String, dynamic>? args})> getSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final route = prefs.getString(_keyLastRoute);
    final argsStr = prefs.getString(_keyRouteArgs);
    Map<String, dynamic>? args;
    if (argsStr != null) {
      try {
        args = jsonDecode(argsStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return (route: route, args: args);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastRoute);
    await prefs.remove(_keyRouteArgs);
  }

  bool isRouteValidForRole(String route, UserRole role) {
    if (role == UserRole.traveler) {
      return !route.startsWith('/driver-') &&
          !route.startsWith('/passenger-') &&
          !route.startsWith('/trip-');
    }
    return route.startsWith('/driver-') ||
        route.startsWith('/passenger-') ||
        route.startsWith('/trip-') ||
        route == AppRouter.notifications;
  }

  bool hasComplexArgs(String route) {
    return _routesWithComplexArgs.contains(route);
  }

  /// Returns whether a saved [route] can be safely restored on cold start.
  ///
  /// Routes with complex (entity) args are never restorable. Routes that
  /// require non-null args are only restorable when their persisted args are
  /// present and valid, so that AppRouter.generateRoute's non-nullable casts
  /// do not crash.
  bool canRestoreRoute(String route, Map<String, dynamic>? savedArgs) {
    if (hasComplexArgs(route)) return false;

    if (route == AppRouter.trips) {
      return savedArgs != null && savedArgs['value'] is String;
    }
    if (route == AppRouter.payment) {
      return savedArgs != null &&
          savedArgs['bookingId'] is String &&
          savedArgs['amount'] is num &&
          savedArgs['travelerName'] is String &&
          savedArgs['travelerPhone'] is String;
    }

    // Routes that take no args are always safe to restore.
    return !_routesRequiringArgs.contains(route);
  }

  dynamic restoreArgsForRoute(String route, Map<String, dynamic>? savedArgs) {
    if (savedArgs == null) return null;
    if (route == AppRouter.trips) {
      return savedArgs['value'] as String?;
    }
    if (route == AppRouter.payment) {
      // Normalize amount to double since JSON may decode it as int.
      return {
        ...savedArgs,
        'amount': (savedArgs['amount'] as num).toDouble(),
      };
    }
    return null;
  }
}

class AppNavigationObserver extends NavigatorObserver {
  final NavigationStateService _service;

  AppNavigationObserver(this._service);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _saveIfNeeded(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _saveIfNeeded(newRoute);
  }

  void _saveIfNeeded(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;
    if (!NavigationStateService._saveableRoutes.contains(name)) return;

    final args = route.settings.arguments;
    Map<String, dynamic>? serializableArgs;
    if (args is Map<String, dynamic>) {
      serializableArgs = args;
    } else if (args is String) {
      serializableArgs = {'value': args};
    } else if (args is int) {
      serializableArgs = {'value': args};
    } else if (args is double) {
      serializableArgs = {'value': args};
    } else if (args is bool) {
      serializableArgs = {'value': args};
    }
    _service.saveRoute(name, serializableArgs);
  }
}
