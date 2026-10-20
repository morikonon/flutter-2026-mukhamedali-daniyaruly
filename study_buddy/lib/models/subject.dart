import 'package:flutter/material.dart';

enum Subject {
  math('Math', Icons.functions),
  programming('Programming', Icons.code),
  physics('Physics', Icons.science),
  languages('Languages', Icons.translate),
  design('Design', Icons.palette),
  business('Business', Icons.business_center);

  const Subject(this.label, this.icon);

  final String label;
  final IconData icon;

  // Exhaustive switch: a new value does not compile until it has a colour.
  Color colorOf(ColorScheme cs) => switch (this) {
    Subject.math => cs.primary,
    Subject.programming => cs.secondary,
    Subject.physics => cs.tertiary,
    Subject.languages => cs.error,
    Subject.design => cs.primaryContainer,
    Subject.business => cs.secondaryContainer,
  };

  /// Text and icons drawn on top of [colorOf] use the matching on-role.
  Color onColorOf(ColorScheme cs) => switch (this) {
    Subject.math => cs.onPrimary,
    Subject.programming => cs.onSecondary,
    Subject.physics => cs.onTertiary,
    Subject.languages => cs.onError,
    Subject.design => cs.onPrimaryContainer,
    Subject.business => cs.onSecondaryContainer,
  };
}
