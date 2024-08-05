import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:demo/screen/student_list_screen.dart'; // Importar a tela onde está a StudentListScreen

void main() async {
  // Assegure-se de que o Flutter esteja totalmente inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o Hive
  await Hive.initFlutter();

  // Abrir caixas (boxes) se necessário
  await Hive.openBox(
      'myBox'); // Substitua 'myBox' pelo nome da caixa que você deseja abrir

  // Inicie o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Van Escolar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          const StudentListScreen(), // Defina StudentListScreen como a tela inicial
    );
  }
}
