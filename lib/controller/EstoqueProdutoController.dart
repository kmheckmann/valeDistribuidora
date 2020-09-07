import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/EstoqueProduto.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/Produto.dart';

class EstoqueProdutoController {
  EstoqueProdutoController();

  Map<String, dynamic> dadosEstoqueProduto = Map();
  List<EstoqueProduto> estoques;

  String proxID(Pedido p, String idItem, DateTime data) {
    //obtem o id pedido, id item e a hora, minutos e segundos atuais pra formar o id do estoque do item
    return p.id +
        "-" +
        idItem +
        "-" +
        data.day.toString() +
        data.month.toString() +
        data.year.toString() +
        data.hour.toString() +
        data.minute.toString() +
        data.second.toString();
  }

  Map<String, dynamic> converterParaMapa(EstoqueProduto estoqueProduto) {
    return {
      "dtAquisicao": estoqueProduto.dataAquisicao,
      "quantidade": estoqueProduto.quantidade,
      "precoCompra": estoqueProduto.precoCompra,
    };
  }

  Future<Null> salvarEstoqueProduto(Map<String, dynamic> dadosEstoqueProduto,
      String idProduto, String idEstoque) async {
    this.dadosEstoqueProduto = dadosEstoqueProduto;
    await Firestore.instance
        .collection("produtos")
        .document(idProduto)
        .collection("estoque")
        .document(idEstoque)
        .setData(dadosEstoqueProduto);
  }

//Método chamado ao finalizar o pedido de compra
  Future<Null> gerarEstoque(Pedido p) async{
    //Busca os dados do pedido
    CollectionReference ref = Firestore.instance.collection("pedidos").document(p.id).collection("itens");
    QuerySnapshot _obterItens = await ref.getDocuments();

//Para cada item do pedido obtem a quantidade e o preço da compra e salva um novo lote do produto
//Aumentando a quantidade em estoque deste item
    _obterItens.documents.forEach((item){
      EstoqueProduto estoque = EstoqueProduto();
      estoque.dataAquisicao = DateTime.now();
      estoque.quantidade = item["quantidade"];
      estoque.precoCompra = item["preco"];
      estoque.id = proxID(p, item.documentID, estoque.dataAquisicao);
      Map<String, dynamic> mapa = converterParaMapa(estoque);
      salvarEstoqueProduto(mapa, item.data["id"], estoque.id);
    });
  }

//Método usado na consulta de estoque
  Future<Null> obterEstoqueProduto(Produto p) async{
    estoques  = List<EstoqueProduto>();
    //Obtém todos os estoque disponiveis
    CollectionReference ref = Firestore.instance.collection("produtos").document(p.id).collection("estoque");
    QuerySnapshot _obterEstoque = await ref.getDocuments();

    //Adiciona cada registro na lista
    _obterEstoque.documents.forEach((document){
      EstoqueProduto e = EstoqueProduto();
      e.id = document.documentID;
      e.dataAquisicao = document.data["dtAquisicao"];
      e.quantidade = document.data["quantidade"];
      e.precoCompra = document.data["precoCompra"];
      estoques.add(e);
    });
  }
}
