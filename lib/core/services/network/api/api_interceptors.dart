import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../routes/routes.dart';
import '../../shared_prefrences/shared_pref.dart';
// Import navigatorKey

class ApiInterceptors extends Interceptor {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = 'en';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _checkForBlacklistedToken(response.data);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.data is Map<String, dynamic>) {
      _checkForBlacklistedToken(err.response?.data);
    }
    super.onError(err, handler);
  }

  void _checkForBlacklistedToken(dynamic data) {
    if (data is Map<String, dynamic> &&
        data["message"] ==
            "The token has been blacklisted, Please login again!") {
      _handleTokenBlacklisted();
    }
  }

  void _handleTokenBlacklisted() async {
    await CacheHelper().removeData(key: "login_token"); // Clear token
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(Routes.splachScreen, (route) => false);
  }
}
