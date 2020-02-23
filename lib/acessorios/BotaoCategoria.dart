import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/screens/TelaProdutosDaCategoria.dart';

class BotaoCategoria extends StatelessWidget {

  //Esse documento snapshot ira ser passado na chamada da TelaProduto, para informar a
  //qual categoria o produto pertence
  final DocumentSnapshot snapshot;

  BotaoCategoria(this.snapshot);

  @override
  Widget build(BuildContext context) {
    //Controi a linha de cada categoria a ser apresentada na tela CategoriaTab
    return ListTile(
      title: Text(
        snapshot.data["titulo"],
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context)=>TelaProdutosDaCategoria(snapshot))
        );
      },
    );
  }
}
