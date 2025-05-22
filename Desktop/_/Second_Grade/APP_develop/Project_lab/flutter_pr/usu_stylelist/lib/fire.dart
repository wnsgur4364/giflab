import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDefault();
  runApp(const MyApp());
}

Future<void> initializeDefault() async {
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  print('initailize default app $app');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter-Firebase Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dbKey = '';
  String dbValue = '';

  Future<void> createData() async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    await realtime.ref().child("test").set({"학번": '12341234',});
  }

  Future<void> readData() async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("test").get();
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    dbKey = value.keys.toString();
    dbValue = value.values.toString();
    setState(() {

    });
  }

  Future<void> updateData() async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    await realtime.ref().child("test").update({"testId": '1234'});
  }


  Future<void> deleteData() async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    await realtime.ref().child("test").remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(200, 30)),
              onPressed: createData,
              child: const Text('CREATE DATA'),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(200, 30)),
              onPressed: readData,
              child: const Text('READ DATA'),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(200, 30)),
              onPressed: updateData,
              child: const Text('UPDATE DATA'),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(200, 30)),
              onPressed: deleteData,
              child: const Text('DELETE DATA'),
            ),
            const SizedBox(height: 10,),
            Text('$dbKey : $dbValue',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
