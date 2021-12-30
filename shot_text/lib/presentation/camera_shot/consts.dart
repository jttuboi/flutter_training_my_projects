import 'package:flutter/material.dart';

final iconButtonStyle = ButtonStyle(
  foregroundColor: MaterialStateProperty.all(Colors.grey.shade300),
  backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5)),
  overlayColor: MaterialStateProperty.all(Colors.white38),
  minimumSize: MaterialStateProperty.all(const Size(40, 40)),
  padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
);

final textButtonStyle = ButtonStyle(
  foregroundColor: MaterialStateProperty.all(Colors.grey.shade300),
  backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5)),
  overlayColor: MaterialStateProperty.all(Colors.white38),
  minimumSize: MaterialStateProperty.all(const Size(40, 40)),
  padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
);
