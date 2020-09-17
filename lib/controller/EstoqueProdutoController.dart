import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/EstoqueProduto.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/Produto.dart';

class EstoqueProdutoController {
  EstoqueProdutoController();

  Map<String, dynamic> dadosEstoqueProduto = Map();
  List<EstoqueProduto> estoques;
  bool produtoTemEstoque = false;
  int qtdeExistente;

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
  Future<Null> gerarEstoque(Pedido p) async {
    //Busca os dados do pedido
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");
    QuerySnapshot _obterItens = await ref.getDocuments();

//Para cada item do pedido obtem a quantidade e o preço da compra e salva um novo lote do produto
//Aumentando a quantidade em estoque deste item
    _obterItens.documents.forEach((item) {
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
  Future<Null> obterEstoqueProduto(Produto p) async {
    estoques = List<EstoqueProduto>();
    //Obtém todos os estoque disponiveis
    CollectionReference ref = Firestore.instance
        .collection("produtos")
        .document(p.id)
        .collection("estoque");
    QuerySnapshot _obterEstoque = await ref.getDocuments();

    //Adiciona cada registro na lista
    _obterEstoque.documents.forEach((document) {
      EstoqueProduto e = EstoqueProduto();
      e.id = document.documentID;
      e.dataAquisicao = document.data["dtAquisicao"];
      e.quantidade = document.data["quantidade"];
      e.precoCompra = document.data["precoCompra"];
      estoques.add(e);
    });
  }

  //Esse método será usado no pedido de venda
  //Ao salvar um item de pedido que nao tenha estoque com a quantidade desejada será exibido um aviso
  //Mas permiirá salvar o item
  //Ao tentar finalizar um pedido onde um dos itens não possui em estoque a quantidade desejada a operação será abortada
  Future<Null> verificarSeProdutoTemEstoqueDisponivel(
      Produto p, int quantidadeDesejada) async {
    //Contador para a quantidade de todos os lotes do item
    qtdeExistente = 0;
    //Chama o método abaixo para obter todo o estoque do item
    await obterEstoqueProduto(p);

    //para cada registro existente, adicionada no contador a quantidade total do lote do estoque
    estoques.forEach((estoqueProduto) {
      qtdeExistente += estoqueProduto.quantidade;
    });

//Se a quantidade existente de estoque for maior ou igual a desejada, atribui true na variavel
    if (qtdeExistente >= quantidadeDesejada) produtoTemEstoque = true;
  }

//Esse método será utilizado no pedido de venda após constatar que existe estoque suficiente disponivel do produto desejado
  Future<Null> descontarEstoqueProduto(
      Produto p, int quantidadeDesejada) async {
    //Contador da lista
    int contador = 0;
    //recebe a quantidade desejada do produto
    int qtdeDesejada = quantidadeDesejada;

//Obtem todo o estoque do produto
    await obterEstoqueProduto(p);

    //Enquanto a quantidade desejada nao estiver zerada será realizado a ação abaixo
    do {
      //Se o lote verificado possuir quantidade maior do que a qtde desejada
      //Subtrai o valor da quantidade desejada e salva a quantidade restante no banco
      if (estoques[contador].quantidade > qtdeDesejada) {
        estoques[contador].quantidade -= qtdeDesejada;
        qtdeDesejada = 0;
      } else {
        //Caso o lote tenha quantidade menor que a qtde desejada
        //Remove-se da quantidade desejada o que o produto tem de quantidade no estoque
        //Zera a quantidade de estoque do item e salva isso no banco
        //Repete o processo até a quantidade desejada ficar zerada
        qtdeDesejada -= estoques[contador].quantidade;
        estoques[contador].quantidade = 0;
      }
      Map<String, dynamic> mapa = converterParaMapa(estoques[contador]);
      salvarEstoqueProduto(mapa, p.id, estoques[contador].id);
    } while (quantidadeDesejada != 0);
  }
}
