import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TaskRepository{

   Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> saveData(List<Map<String, dynamic>> task) async {
    String data = json.encode(task);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}