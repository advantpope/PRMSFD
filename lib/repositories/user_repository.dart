import 'dart:io';

import 'package:hive/hive.dart';
import 'package:map/network/http.dart';
import 'package:map/middlewares/propowner.dart';
import 'package:file_picker/file_picker.dart';
import '../middlewares/user.dart';
import 'package:csv/csv.dart';

class UserRepository {
  // List<User>? _cache;

  final _box = Hive.box<User>('usersBox');

  final _propBox = Hive.box<PropertyOwener>('propertyOwnerBox');

  Future<void> importCSVToHiveOptimized() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final csvString = await file.readAsString();

    final rows = const CsvToListConverter().convert(csvString);

    final List<PropertyOwener> batch = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      batch.add(
        PropertyOwener(
          name: row[0].toString(),
          valuation: row[1].toString(),
          amount: row[2].toString(),
          latitude: row[3].toString(),
          longitude: row[4].toString(),
        ),
      );
    }

    await _propBox.addAll(batch); // 🚀 FAST
  }

  Future<List<User>> fetchUsers({bool forceRefresh = false}) async {
    // if (_cache != null && !forceRefresh) {
    //   return _cache!;
    // }
    if (!forceRefresh && _box.isNotEmpty) {
      return _box.values.toList();
    }
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final response = await DioClient.dio.get('/users');

    final List<dynamic> data = response.data;
    final users = data.map((json) => User.fromJson(json)).toList();
    await _box.clear();
    // for (var user in users) {
    //   await _box.add(user);
    // }
    await _box.addAll(users);
    return users;
    // Simulated fetched data
    // final response = await http.get(
    //   Uri.parse('https://jsonplaceholder.typicode.com/users'),
    // );

    //   if (response.statusCode == 200) {
    //     final List<dynamic> data = jsonDecode(response.body);
    //     _cache = data.map((json) => User.fromJson(json)).toList();
    //     return _cache!;
    //   } else {
    //     throw Exception('Failed to load users');
    //   }
  }
}
