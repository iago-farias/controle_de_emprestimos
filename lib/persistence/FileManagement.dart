import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class FileManagement {
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/emprestimos.json");
  }

  Future<String> readEmprestimo() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> saveEmprestimo(List emprestimoList) async {
    String data = json.encode(emprestimoList, toEncodable: myEncode);
    final file = await _getFile();  	
    return file.writeAsString(data);
  }

  //Função usada para converter o tipo de dados Datetime para json
  dynamic myEncode(dynamic item) {
    if(item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}