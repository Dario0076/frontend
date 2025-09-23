import 'package:flutter/material.dart';
import 'export_excel_web.dart'
    if (dart.library.io) 'export_excel_io.dart'
    as excel_impl;

Future<void> exportarStockExcel(
  List<List<dynamic>> rows,
  BuildContext context,
) async {
  await excel_impl.exportarExcel(rows, context);
}
