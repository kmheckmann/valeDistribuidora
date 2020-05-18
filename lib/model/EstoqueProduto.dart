import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Produto.dart';

class EstoqueProduto{

  String id;
  DateTime dataAquisicao;
  double precoCompra;
  int quantidade;
  Produto produto = Produto();

  EstoqueProduto();

  EstoqueProduto.buscarFirebase(DocumentSnapshot snapshot){
    //Recebe p DocumentSnaposhot como parâmetro e atribui os valores a cada variável
    //DocumentSnapshot contém as informações obtidas do firebase
    id = snapshot.documentID;
    dataAquisicao = snapshot.data["dtAquisicao"];
    quantidade = snapshot.data["quantidade"];
    precoCompra = snapshot.data["precoCompra"] + 0.0;
  }

}