import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:map/layouts/home.dart';
import 'package:map/middlewares/propowner.dart';
import 'package:map/middlewares/user.dart';
import 'package:map/middlewares/address.dart';
import 'package:map/middlewares/geocode.dart';
import 'package:map/values/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('searchHistoryBox');
  final exists = await Hive.boxExists('searchHistoryBox');
  print('Box exists: $exists');
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(GeocodeAdapter());
  Hive.registerAdapter(PropertyOwenerAdapter());
  await Hive.openBox<User>('usersBox');
  await Hive.openBox<PropertyOwener>('propertyOwnerBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Home(
        title: AppStrings.appTitle,
        color: const Color.fromARGB(255, 74, 207, 125),
      ),
    );
  }
}
