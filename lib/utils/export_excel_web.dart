import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'dart:html' as html;

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
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'stock.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Exportación exitosa: archivo Excel descargado.'),
    ),
  );
}
