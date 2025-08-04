import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceUtils {
  /// Optimize widget rebuilds by using RepaintBoundary for complex widgets
  static Widget optimizeWidget(Widget child, {String? debugLabel}) {
    return RepaintBoundary(
      child: child,
    );
  }

  /// Debounce function calls to prevent excessive rebuilds
  static Function debounce(Function func, Duration wait) {
    Timer? timer;
    return (dynamic arg) {
      timer?.cancel();
      timer = Timer(wait, () => func(arg));
    };
  }

  /// Throttle function calls to limit execution frequency
  static Function throttle(Function func, Duration wait) {
    DateTime? lastRun;
    return (dynamic arg) {
      final now = DateTime.now();
      if (lastRun == null || now.difference(lastRun!) >= wait) {
        lastRun = now;
        func(arg);
      }
    };
  }

  /// Schedule a frame callback to prevent layout issues
  static void scheduleFrameCallback(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  /// Safe setState that checks if widget is mounted
  static void safeSetState(State state, VoidCallback fn) {
    if (state.mounted) {
      state.setState(fn);
    }
  }

  /// Optimize list items with proper constraints
  static Widget optimizedListItem({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }

  /// Create a constrained box to prevent layout issues
  static Widget constrainedBox({
    required Widget child,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0.0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0.0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: child,
    );
  }

  /// Optimize text widgets to prevent layout issues
  static Widget optimizedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? width,
    double? height,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 0.0,
        maxWidth: width ?? double.infinity,
        minHeight: height ?? 0.0,
        maxHeight: height ?? double.infinity,
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// Create a loading placeholder with proper constraints
  static Widget loadingPlaceholder({
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Error placeholder with proper constraints
  static Widget errorPlaceholder({
    required String message,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
} 