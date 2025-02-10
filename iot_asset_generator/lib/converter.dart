import 'dart:convert';
import 'dart:io';

Future<void> convertToJsonl(String fileName) async {
  try {
    // Read the JSON file
    final file = File(fileName);
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);
    
    // Create JSONL file
    final jsonlFile = File('assets.jsonl');
    final sink = jsonlFile.openWrite();
    
    // Convert each object to JSONL format
    for (var item in jsonData) {
      sink.writeln(json.encode(item));
    }
    
    await sink.close();
    print('Conversion complete: assets.jsonl created');
  } catch (e) {
    print('Error converting file: $e');
  }
}