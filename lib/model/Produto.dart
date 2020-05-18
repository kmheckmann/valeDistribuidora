import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Categoria.dart';

class Produto{

  //ID do documento no firebase
  String id;

  int codigo;
  int codBarra;
  String descricao;
  double percentualLucro;
  bool ativo;
  Categoria categoria = Categoria();

  Produto();

  Produto.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    descricao = snapshot.data["descricao"];
    codigo = snapshot.data["codigo"];
    codBarra = snapshot.data["codBarra"];
    percentualLucro = snapshot.data["percentLucro"];
    ativo = snapshot.data["ativo"];
  }
}