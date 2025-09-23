import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> exportarExcel(
  List<List<dynamic>> rows,
  BuildContext context,
) async {
  final excel = ex.Excel.createExcel();
  final sheet = excel['Stock'];
  for (final row in rows) {
    sheet.appendRow(row);
  }
  final bytes = excel.encode();
  try {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    final file = io.File('${directory.path}/stock.xlsx');
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exportación exitosa: archivo guardado en ${file.path}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo generar el archivo Excel.'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al guardar archivo: $e')));
  }
}
