import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Cross-platform icon provider that works consistently on web and mobile
///
/// Usage:
/// - AppIcons.walk() - Walking/steps icon
/// - AppIcons.database() - Database/storage icon
/// - AppIcons.brain() - AI/psychology icon
/// - AppIcons.refresh() - Refresh icon
/// - AppIcons.health() - Health/medical icon
///
/// Set useFluentUI to true for consistent web icons, false for Material Icons
class AppIcons {
  static const bool useFluentUI =
      false; // Using Material Icons for now, change to true when FluentUI icons are fixed

  // Navigation icons - using basic FluentUI icon names that should exist
  static IconData walk() => useFluentUI
      ? FluentIcons.person_walking_20_regular
      : Icons.directions_walk;
  static IconData database() =>
      useFluentUI ? FluentIcons.database_20_regular : Icons.storage;
  static IconData brain() =>
      useFluentUI ? FluentIcons.brain_circuit_20_regular : Icons.psychology;

  // Action icons
  static IconData refresh() =>
      useFluentUI ? FluentIcons.arrow_clockwise_20_regular : Icons.refresh;
  static IconData clear() =>
      useFluentUI ? FluentIcons.dismiss_20_regular : Icons.clear;
  static IconData delete() =>
      useFluentUI ? FluentIcons.delete_20_regular : Icons.delete;
  static IconData info() =>
      useFluentUI ? FluentIcons.info_20_regular : Icons.info_outline;

  // Health and status icons
  static IconData health() => useFluentUI
      ? FluentIcons.heart_pulse_20_regular
      : Icons.health_and_safety;
  static IconData healthOutlined() => useFluentUI
      ? FluentIcons.heart_20_regular
      : Icons.health_and_safety_outlined;
  static IconData checkCircle() => useFluentUI
      ? FluentIcons.checkmark_circle_20_regular
      : Icons.check_circle;
  static IconData error() =>
      useFluentUI ? FluentIcons.error_circle_20_regular : Icons.error;
  static IconData warning() =>
      useFluentUI ? FluentIcons.warning_20_regular : Icons.hourglass_empty;

  // UI interaction icons
  static IconData expandLess() =>
      useFluentUI ? FluentIcons.chevron_up_20_regular : Icons.expand_less;
  static IconData expandMore() =>
      useFluentUI ? FluentIcons.chevron_down_20_regular : Icons.expand_more;
  static IconData person() =>
      useFluentUI ? FluentIcons.person_20_regular : Icons.person;

  // Alternative icon methods for easy switching
  static Icon walkIcon({double? size, Color? color}) =>
      Icon(walk(), size: size, color: color);
  static Icon databaseIcon({double? size, Color? color}) =>
      Icon(database(), size: size, color: color);
  static Icon brainIcon({double? size, Color? color}) =>
      Icon(brain(), size: size, color: color);
  static Icon refreshIcon({double? size, Color? color}) =>
      Icon(refresh(), size: size, color: color);
  static Icon clearIcon({double? size, Color? color}) =>
      Icon(clear(), size: size, color: color);
  static Icon deleteIcon({double? size, Color? color}) =>
      Icon(delete(), size: size, color: color);
  static Icon infoIcon({double? size, Color? color}) =>
      Icon(info(), size: size, color: color);
  static Icon healthIcon({double? size, Color? color}) =>
      Icon(health(), size: size, color: color);
  static Icon checkIcon({double? size, Color? color}) =>
      Icon(checkCircle(), size: size, color: color);
  static Icon errorIcon({double? size, Color? color}) =>
      Icon(error(), size: size, color: color);
  static Icon warningIcon({double? size, Color? color}) =>
      Icon(warning(), size: size, color: color);
  static Icon expandLessIcon({double? size, Color? color}) =>
      Icon(expandLess(), size: size, color: color);
  static Icon expandMoreIcon({double? size, Color? color}) =>
      Icon(expandMore(), size: size, color: color);
  static Icon personIcon({double? size, Color? color}) =>
      Icon(person(), size: size, color: color);
}
