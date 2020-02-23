import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/acessorios/BotaoCategoria.dart';

class CategoriaTab extends StatelessWidget {
  //tela que vai exibir cada uma das categorias
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      //Utiliza o futureBuilde pq os dados vem do firebase
      //e pode demorar um pouco para vim
      future: Firestore.instance.collection("produtos").getDocuments(), //buscando os dados
      builder: (context, snapshot) {
        //se nao tiver dado no snapshot indica que esta carregando
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          //se tem dados apresenta as categorias

          //isso eh para apresentar uma linha fina entre cada uma da categoria listada
          var _dividir = ListTile.divideTiles(
            tiles: snapshot.data.documents.map((doc) {
              return BotaoCategoria(doc);
            }).toList(),
            color: Colors.grey
          ).toList();

          return ListView(children: _dividir);
        }
      },
    );
  }
}
