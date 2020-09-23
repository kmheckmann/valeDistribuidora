import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Usuario.dart';

class PedidoController {
  PedidoCompra pedidoCompra = PedidoCompra();
  PedidoVenda pedidoVenda = PedidoVenda();
  Empresa empresa = Empresa();
  Usuario usuario = Usuario();
  bool podeFinalizar = false;

  PedidoController();

  String proxID;

  Map<String, dynamic> dadosPedido = Map();
  Map<String, dynamic> dadosUsuario = Map();
  Map<String, dynamic> dadosEmpresa = Map();

  Future<Null> obterProxID() async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("pedidos");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      docID = int.parse(document.documentID);
      if (eventsQuery.documents.length == 0) {
        idTemp = 1;
        proxID = idTemp.toString();
      } else {
        if (docID > idTemp) {
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp + 1;
    proxID = idTemp.toString();
  }

  Map<String, dynamic> converterParaMapa(Pedido p) {
    return {
      "valorTotal": p.valorTotal,
      "percentualDesconto": p.percentualDesconto,
      "tipoPagamento": p.tipoPagamento,
      "ehPedidoVenda": p.ehPedidoVenda,
      "dataPedido": p.dataPedido,
      "pedidoFinalizado": p.pedidoFinalizado,
      "label": p.labelTelaPedidos,
      "valorComDesconto": p.valorComDesconto,
      "dataFinalPedido": p.dataFinalPedido,
    };
  }

  Future<Null> salvarPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idPedido) async {
    this.dadosPedido = dadosPedido;
    this.dadosEmpresa = dadosEmpresa;
    this.dadosUsuario = dadosUsuario;

    //Grava os dados do pedido
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);

    //Salva dentro da collection pedido o ID do cliente do pedido
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosEmpresa);
    //Salva dentro da collection pedido o ID do vendedor
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosUsuario);
  }

  Future<Null> editarPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idFirebase) async {
    this.dadosPedido = dadosPedido;
    this.dadosEmpresa = dadosEmpresa;
    this.dadosUsuario = dadosUsuario;
    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .setData(dadosPedido);

    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosEmpresa);

    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosUsuario);
  }

//Método que grava os itens do pedido
  void adicionarItem(ItemPedido item, String idPedido, String idProduto,
      Map<String, dynamic> dadosPedido) {
    this.dadosPedido = dadosPedido;

//Grava as informações do item do pedido
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(item.id)
        .setData(item.converterParaMapa(idProduto));
//Informações do item podem influenciar em valores da capa do pedido, como preço total, ao salvar os itens
//salva também as atualizações que podem ter tido no pedido em si
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

//Grava as edições do item do pedido e consequentemente edições do pedido em si também
  void editarItem(ItemPedido item, String idPedido, String idProduto,
      Map<String, dynamic> dadosPedido) {
    this.dadosPedido = dadosPedido;
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(item.id)
        .setData(item.converterParaMapa(idProduto));

    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

//Método para remover um item do pedido
  void removerItem(ItemPedido item, String idItem, String idPedido,
      Map<String, dynamic> dadosPedido) {
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(idItem)
        .delete();

//Ao remover um item atualiza as informações do pedido em si
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

//Busca os dados da empresa vinculada ao pedido
  Future<Null> obterEmpresa(String idPedido) async {
    Empresa e = Empresa();
    //Acessa a collection em que a empresa está
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('cliente');
//Obtem a empresa
    QuerySnapshot obterEmpresaPedido = await ref.getDocuments();

//Acessa a collection de todas as empresas cadastradas e pega todas as empresas
    CollectionReference refCliente = Firestore.instance.collection('empresas');
    QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

//Compara o ID da empresa vinculada ao pedido com as existentes até encontrar o correspondente
//Após isso busca as outras informações além do ID
    obterEmpresaPedido.documents.forEach((document) {
      e.id = document.data["id"];

      obterDadosEmpresa.documents.forEach((document1) {
        if (e.id == document1.documentID) {
          e = Empresa.buscarFirebase(document1);
        }
      });
    });
    empresa = e;
  }

//Método para obter as informações do vendedor do pedido
  Future<Null> obterUsuario(String idPedido) async {
    Usuario user = Usuario();
    //Obtem o ID do vendedor do pedido
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('vendedor');
    QuerySnapshot obterUsuario = await ref.getDocuments();

//Obtem todos os usuarios cadastrados
    CollectionReference refCliente = Firestore.instance.collection('usuarios');
    QuerySnapshot obterDadosUsuario = await refCliente.getDocuments();

//Compara o ID do vendedor do pedido com todos os cadastrados até encontrar um igual
//Após isso obtém as demais informações do vendedor
    obterUsuario.documents.forEach((document) {
      user.id = document.data["id"];

      obterDadosUsuario.documents.forEach((document1) {
        if (user.id == document1.documentID) {
          user = Usuario.buscarFirebase(document1);
        }
      });
    });
    usuario = user;
  }

//Aplica no valor total do pedido o desconto informado
  void calcularDesconto(Pedido p) {
    if (p.valorTotal != 0 || p.valorTotal == 0) {
      double vlDesc = (p.percentualDesconto / 100) * p.valorTotal;
      pedidoCompra.valorComDesconto = (p.valorTotal - vlDesc);
      pedidoVenda.valorComDesconto = (p.valorTotal - vlDesc);
    } else {
      //Exceção para o caso de o desconto ser informado antes do pedido ter algum valor
      pedidoVenda.valorComDesconto = 0;
      pedidoCompra.valorComDesconto = 0;
    }
  }

//Método chamado para atualizar regularmente o valor total do pedido
  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem) {
    double valorTotalItem = novoItem.preco * novoItem.quantidade;
    p.valorTotal += valorTotalItem;
    pedidoCompra.valorTotal = p.valorTotal;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

//Método utilizado quando é realizada uma alteração num item do pedido
  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    //Diminui o valor total antigo obtido com a soma das quantidade do item
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.valorTotal -= vlTotalItemAntigo;
    //Após diminuir, chama o método abaixo para somar o novo valor no pedido
    somarPrecoNoVlTotal(p, item);
  }

//Método utilizado quando um item é removido, para diminuir seu valor do valor total do pedido
  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido) {
    double valorTotalItem = itemExcluido.preco * itemExcluido.quantidade;
    p.valorTotal -= valorTotalItem;
    pedidoCompra.valorTotal = p.valorTotal;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

//Método chamado ao utilizar o botão de atualizar na capa do pedido
  Future<Null> atualizarCapaPedido(String idPedido) async {
    CollectionReference ref = Firestore.instance.collection('pedidos');
    QuerySnapshot _obterPedido = await ref.getDocuments();

    _obterPedido.documents.forEach((document) {
      if (idPedido == document.documentID) {
        pedidoVenda = PedidoVenda.buscarFirebase(document);
        pedidoCompra = PedidoCompra.buscarFirebase(document);
      }
    });
  }

  Future<Null> verificarSePedidoTemItens(Pedido p) async {
    //este método tem o objetivo de verificar se o pedido possui itens cadastrados
    //para poder finalizar o pedido

    //Acessa a coleção onde os iens ficam salvos
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");
    //Obtém todos os documentos da coleção
    QuerySnapshot _obterItens = await ref.getDocuments();

    if (_obterItens.documents.length > 0) {
      podeFinalizar = true;
    } else {
      podeFinalizar = false;
    }
  }
}
