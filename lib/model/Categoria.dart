import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria{
  String id;
  String descricao;
  bool ativa;

  Categoria();

  Categoria.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    descricao = snapshot.data["descricao"];
    ativa = snapshot.data["ativa"];
  }
}