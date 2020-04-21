import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaInicial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //O scopedModel eh para conseguir acessar a classe usuario de qualquer lugar do app
    return ScopedModel<Usuario>(
      model: Usuario(),
      child: MaterialApp(
        title: 'TCC',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color.fromARGB(255, 0, 120, 189)
        ),
        debugShowCheckedModeBanner: false,
        home: TelaInicial(),
      ),
    );
  }
}
