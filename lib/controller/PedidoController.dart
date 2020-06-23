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
      "valorComDesconto": p.valorComDesconto
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
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);

    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosEmpresa);

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

  void adicionarItem(ItemPedido item, String idPedido, String idProduto,
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

  void removerItem(ItemPedido item, String idItem, String idPedido,
      Map<String, dynamic> dadosPedido) {
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(idItem)
        .delete();

    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

  Future<Null> obterEmpresa(String idPedido) async {
    Empresa e = Empresa();
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('cliente');
    QuerySnapshot obterEmpresaPedido = await ref.getDocuments();

    CollectionReference refCliente = Firestore.instance.collection('empresas');
    QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

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

  Future<Null> obterUsuario(String idPedido) async {
    Usuario user = Usuario();
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('vendedor');
    QuerySnapshot obterUsuario = await ref.getDocuments();

    CollectionReference refCliente = Firestore.instance.collection('usuarios');
    QuerySnapshot obterDadosUsuario = await refCliente.getDocuments();

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

  void calcularDesconto(Pedido p) {
    if (p.valorTotal != 0 || p.valorTotal == 0) {
      double vlDesc = (p.percentualDesconto / 100) * p.valorTotal;
      pedidoCompra.valorComDesconto = (p.valorTotal - vlDesc);
      pedidoVenda.valorComDesconto = (p.valorTotal - vlDesc);
    } else {
      pedidoVenda.valorComDesconto = 0;
      pedidoCompra.valorComDesconto = 0;
    }
  }

  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem) {
    double valorTotalItem = novoItem.preco * novoItem.quantidade;
    p.valorTotal += valorTotalItem;
    pedidoCompra.valorTotal = p.valorTotal;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.valorTotal -= vlTotalItemAntigo;
    somarPrecoNoVlTotal(p, item);
  }

  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido) {
    double valorTotalItem = itemExcluido.preco * itemExcluido.quantidade;
    p.valorTotal -= valorTotalItem;
    pedidoCompra.valorTotal = p.valorTotal;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

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
    //este método tem o objetivo de verificar se o pedido possui itens cadastrados para poder finalizar o pedido
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");
    QuerySnapshot _obterItens = await ref.getDocuments();

    if (_obterItens.documents.length > 0) {
      podeFinalizar = true;
    } else {
      podeFinalizar = false;
    }
  }
}
