import 'package:cloud_firestore/cloud_firestore.dart';

class Cidade {
  //ID do documento no firebase
  String id;

  String nome;
  String estado;
  bool ativa;

  Cidade();

  Cidade.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    nome = snapshot.data["nome"];
    estado = snapshot.data["estado"];
    ativa = snapshot.data["ativa"];
  }
}
