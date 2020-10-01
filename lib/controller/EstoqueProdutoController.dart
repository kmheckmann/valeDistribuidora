import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/EstoqueProduto.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Produto.dart';

class EstoqueProdutoController {
  EstoqueProdutoController();

  Map<String, dynamic> dadosEstoqueProduto = Map();
  ProdutoController _controllerProduto = ProdutoController();
  List<EstoqueProduto> estoques = List<EstoqueProduto>();
  List<Produto> produtos = List<Produto>();
  bool produtoTemEstoque = false;
  bool permitirFinalizarPedidoVenda = true;
  int qtdeExistente;
  double precoVenda = 0;

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
    //Obtém todos os estoque disponiveis
    CollectionReference ref = Firestore.instance
        .collection("produtos")
        .document(p.id)
        .collection("estoque");
    QuerySnapshot _obterEstoque =
        await ref.getDocuments();

    //Adiciona cada registro na lista
    _obterEstoque.documents.forEach((document) {
      EstoqueProduto e = EstoqueProduto();
      e = EstoqueProduto.buscarFirebase(document);
      /*e.id = document.documentID;
      e.dataAquisicao = document.data["dtAquisicao"];
      e.quantidade = document.data["quantidade"];
      e.precoCompra = document.data["precoCompra"];*/
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
    obterEstoqueProduto(p);

    //para cada registro existente, adicionada no contador a quantidade total do lote do estoque
    estoques.forEach((estoqueProduto) {
      qtdeExistente += estoqueProduto.quantidade;
    });

//Se a quantidade existente de estoque for maior ou igual a desejada, atribui true na variavel
    if (qtdeExistente >= quantidadeDesejada) produtoTemEstoque = true;
  }

//Esse método será utilizado no pedido de venda após constatar que existe estoque suficiente disponivel do produto desejado
  Future<Null> descontarEstoqueProduto(Pedido p) async {
    int contador;
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");

    QuerySnapshot _obterItens = await ref.getDocuments();

    _obterItens.documents.forEach((item) async {
      contador = 0;
      await _controllerProduto.obterProdutoPorID(item.data["id"]);
      Produto prod = _controllerProduto.produto;
      //Contador da lista
      //recebe a quantidade desejada do produto
      int qtdeDesejada = item.data["quantidade"];

      //Obtem todo o estoque do produto
      await obterEstoqueProduto(prod);
      print("passou");
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
        salvarEstoqueProduto(mapa, prod.id, estoques[contador].id);
        contador += 1;
      } while (qtdeDesejada != 0);
    });
  }

  Future<Null> verificarEstoqueTodosItensPedido(PedidoVenda pedido) async {
    //Metodo criado para verificar se todos os itens do pedido possuem estoque
    //se sim, sera possível finalizar o pedido, caso contrário não será permitido

    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(pedido.id)
        .collection("itens");

    QuerySnapshot _obterItens = await ref.getDocuments();

    _obterItens.documents.forEach((item) async{
      _controllerProduto.obterProdutoPorID(item.data["id"]);
      Produto prod = _controllerProduto.produto;
      //Contador da lista
      //recebe a quantidade desejada do produto
      int qtdeDesejada = item.data["quantidade"];

      await verificarSeProdutoTemEstoqueDisponivel(prod, qtdeDesejada);

      if (produtoTemEstoque == false) {
        permitirFinalizarPedidoVenda = false;
      }
    });
  }

//O metodo ira aplicar no maior preco de compra do item o percentual de lucro definido no cadastro do produto
  Future<Null> obterPrecoVenda(Produto p) async {
    double preco = 0;
    double maiorPrecoCompra = 0;

    await obterEstoqueProduto(p);

    estoques.forEach((item) {
      preco = item.precoCompra;
      if (preco > maiorPrecoCompra) {
        maiorPrecoCompra = preco;
      }
    });

    precoVenda =
        ((p.percentualLucro / 100) * maiorPrecoCompra) + maiorPrecoCompra;
  }
}
