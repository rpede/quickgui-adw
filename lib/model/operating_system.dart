import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'version.dart';

@immutable
class OperatingSystem extends Equatable {
  OperatingSystem({
    required this.name,
    required this.code,
    this.png,
    this.svg,
    List<Version>? versions,
  }) : versions = versions ?? [];

  final String name;
  final String code;
  final String? png;
  final String? svg;
  final List<Version> versions;
  
  @override
  List<Object?> get props => [name, code, png, svg, versions];
}
