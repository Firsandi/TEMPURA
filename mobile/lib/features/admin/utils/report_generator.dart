import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ReportGenerator {
  static Future<String> generatePdf(Map<String, dynamic> batch, List<dynamic> runs) async {
    final pdf = pw.Document();
    
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Laporan Produksi Tempura", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Nama Batch: ${batch['nama_batch']}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Jumlah Kedelai: ${batch['jumlah_kedelai']} kg", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Jumlah Ragi: ${batch['jumlah_ragi']} gram", style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Text("Riwayat Produksi:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Run', 'Mulai', 'Dihentikan', 'Status', 'Oleh'],
                data: runs.map((run) {
                  final startTime = DateTime.parse(run['start_time']).toLocal();
                  final startStr = dateFormat.format(startTime);
                  
                  String endStr = '-';
                  if (run['end_time'] != null) {
                    final endTime = DateTime.parse(run['end_time']).toLocal();
                    endStr = dateFormat.format(endTime);
                  }
                  
                  String actor = "Mulai: ${run['started_by_name'] ?? 'Sistem'}\nStop: ${run['stopped_by_name'] ?? '-'}";

                  return [
                    run['run_number'].toString(),
                    startStr,
                    endStr,
                    run['status'] ?? '-',
                    actor,
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/Laporan_Batch_${batch['batch_id']}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static Future<String> generateExcel(Map<String, dynamic> batch, List<dynamic> runs) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Laporan'];
    excel.setDefaultSheet('Laporan');

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    // Title
    sheetObject.appendRow([TextCellValue("Laporan Produksi Tempura")]);
    sheetObject.appendRow([TextCellValue("Nama Batch: ${batch['nama_batch']}")]);
    sheetObject.appendRow([TextCellValue("Jumlah Kedelai: ${batch['jumlah_kedelai']} kg")]);
    sheetObject.appendRow([TextCellValue("Jumlah Ragi: ${batch['jumlah_ragi']} gram")]);
    sheetObject.appendRow([TextCellValue("")]); // empty row

    // Headers
    sheetObject.appendRow([
      TextCellValue('Run Number'),
      TextCellValue('Waktu Mulai'),
      TextCellValue('Dimulai Oleh'),
      TextCellValue('Waktu Dihentikan'),
      TextCellValue('Dihentikan Oleh'),
      TextCellValue('Status'),
    ]);

    // Data
    for (var run in runs) {
      final startTime = DateTime.parse(run['start_time']).toLocal();
      final startStr = dateFormat.format(startTime);
      
      String endStr = '-';
      if (run['end_time'] != null) {
        final endTime = DateTime.parse(run['end_time']).toLocal();
        endStr = dateFormat.format(endTime);
      }

      sheetObject.appendRow([
        IntCellValue(run['run_number']),
        TextCellValue(startStr),
        TextCellValue(run['started_by_name'] ?? 'Sistem'),
        TextCellValue(endStr),
        TextCellValue(run['stopped_by_name'] ?? '-'),
        TextCellValue(run['status'] ?? '-'),
      ]);
    }

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/Laporan_Batch_${batch['batch_id']}.xlsx");
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }
}
