import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Categoria.dart';

class Produto{

  //ID do documento no firebase
  String id;

  int codigo;
  int codBarra;
  String descricao;
  double precoCompra;
  double precoVenda;
  int qtdEstoque;
  bool ativo;
  Categoria categoria = Categoria();

  Produto();

  Produto.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    descricao = snapshot.data["descricao"];
    codigo = snapshot.data["codigo"];
    codBarra = snapshot.data["codBarra"];
    //somar o 0.0 no final eh uma alternativa para corrigir um bug quando busca um valor sem casas decimais do firebase
    precoCompra = snapshot.data["precoCompra"] + 0.0;
    precoVenda = snapshot.data["precoVenda"] + 0.0;
    qtdEstoque = snapshot.data["qtdEstoque"];
    ativo = snapshot.data["ativo"];
  }
}