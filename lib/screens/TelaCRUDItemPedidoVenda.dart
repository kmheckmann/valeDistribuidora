import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/EstoqueProdutoController.dart';
import 'package:tcc_2/controller/ItemPedidoController.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Produto.dart';
import 'package:tcc_2/screens/TelaItensPedidoVenda.dart';

class TelaCRUDItemPedidoVenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaCRUDItemPedidoVenda({this.pedidoVenda, this.itemPedido, this.snapshot});
  @override
  _TelaCRUDItemPedidoVendaState createState() => _TelaCRUDItemPedidoVendaState(
      snapshot: snapshot, pedidoVenda: pedidoVenda, itemPedido: itemPedido);
}

class _TelaCRUDItemPedidoVendaState extends State<TelaCRUDItemPedidoVenda> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  ItemPedido itemPedido;

  _TelaCRUDItemPedidoVendaState(
      {this.snapshot, this.pedidoVenda, this.itemPedido});

  String _dropdownValueProduto;
  double vlItemAntigo;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  final _controllerProd = TextEditingController();
  bool _novocadastro;
  bool _temEstoque = false;
  String _nomeTela;
  Produto produto = Produto();
  Stream<QuerySnapshot> _produtos;

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  ProdutoController _controllerProduto = ProdutoController();
  ItemPedidoController _controllerItemPedido = ItemPedidoController();
  PedidoController _controllerPedido = PedidoController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  @override
  void initState() {
    super.initState();
    _produtos = Firestore.instance.collection("produtos").snapshots();
    if (itemPedido != null) {
      _nomeTela = "Editar Produto";
      vlItemAntigo = itemPedido.preco;
      _dropdownValueProduto = itemPedido.produto.descricao;
      _controllerPreco.text = itemPedido.preco.toString();
      _controllerQtde.text = itemPedido.quantidade.toString();
      _novocadastro = false;
    } else {
      _nomeTela = "Novo Produto";
      itemPedido = ItemPedido(pedidoVenda);
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      floatingActionButton: Visibility(
          visible: pedidoVenda.pedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_validadorCampos.currentState.validate()) {
                  if (_dropdownValueProduto != null) {
                    await _controllerProduto
                        .obterProdutoPorDescricao(_dropdownValueProduto);
                    produto = _controllerProduto.produto;

                    await _controllerEstoque
                        .verificarSeProdutoTemEstoqueDisponivel(
                            produto, itemPedido.quantidade);
                    _temEstoque = _controllerEstoque.produtoTemEstoque;
                    if (!_temEstoque) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _alertaEstoqueProduto(
                                _controllerEstoque.qtdeExistente);
                          });
                    } else {
                      _codigoPersistir();
                    }
                  } else {
                    _scaffold.currentState.showSnackBar(SnackBar(
                      content: Text("É necessário selecionar um produto!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                    ));
                  }
                }
              })),
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _campoProduto(),
              _criarCampoTexto(_controllerPreco, "Preço", TextInputType.number),
              _criarCampoTexto(
                  _controllerQtde, "Quantidade", TextInputType.number),
            ],
          )),
    );
  }

  Widget _criarDropDownProduto() {
    return StreamBuilder<QuerySnapshot>(
        stream: _produtos,
        builder: (context, snapshot) {
          var length = snapshot.data.documents.length;
          DocumentSnapshot ds = snapshot.data.documents[length - 1];
          return Container(
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 336.0,
                  child: DropdownButton(
                    value: _dropdownValueProduto,
                    hint: Text("Selecionar produto"),
                    onChanged: (String newValue) {
                      setState(() {
                        _dropdownValueProduto = newValue;
                        itemPedido.labelListaProdutos = _dropdownValueProduto;
                      });
                    },
                    items: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                          value: document.data['descricao'],
                          child: Container(
                            child: Text(
                                document.documentID +
                                    ' - ' +
                                    document.data['descricao'],
                                style: TextStyle(color: Colors.black)),
                          ));
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  TextStyle _style() {
    if (pedidoVenda.pedidoFinalizado) {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    }
  }

  Widget _criarCampoTexto(
      TextEditingController _controller, String titulo, TextInputType tipo) {
    return TextFormField(
      controller: _controller,
      enabled: pedidoVenda.pedidoFinalizado ? false : true,
      keyboardType: tipo,
      decoration: InputDecoration(
          hintText: titulo,
          labelText: titulo,
          labelStyle:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
      style: _style(),
      validator: (text) {
        if (_controller.text.isEmpty)
          return "É necessário preencher este campo!";
      },
      onChanged: (texto) {
        if (titulo == "Preço") itemPedido.preco = double.parse(texto);
        if (titulo == "Quantidade") itemPedido.quantidade = int.parse(texto);
      },
    );
  }

  Widget _campoProduto() {
    _controllerProd.text = _dropdownValueProduto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(_controllerProd, "Produto", TextInputType.text);
    } else {
      return _criarDropDownProduto();
    }
  }

  Widget _alertaEstoqueProduto(int qtde) {
    return AlertDialog(
      title: Text('Produto sem estoque'),
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'O produto não possui estoque suficiente para atender o pedido'),
            Text('Quantidade existente: $qtde'),
            Text('Deseja continuar?')
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Não'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Sim'),
          onPressed: () {
            Navigator.of(context).pop();
            _codigoPersistir();
          },
        ),
      ],
    );
  }

  void _codigoPersistir() async {
    if (_novocadastro) {
      await _controllerItemPedido.obterProxID(pedidoVenda.id);
      itemPedido.id = _controllerItemPedido.proxID;
      _controllerPedido.somarPrecoNoVlTotal(pedidoVenda, itemPedido);
      pedidoVenda.valorTotal = _controllerPedido.pedidoVenda.valorTotal;
      pedidoVenda.valorComDesconto =
          _controllerPedido.pedidoVenda.valorComDesconto;
      _controllerPedido.adicionarItem(itemPedido, pedidoVenda.id, produto.id,
          pedidoVenda.converterParaMapa());
    } else {
      _controllerPedido.atualizarPrecoNoVlTotal(
          vlItemAntigo, pedidoVenda, itemPedido);
      pedidoVenda.valorTotal = _controllerPedido.pedidoVenda.valorTotal;
      pedidoVenda.valorComDesconto =
          _controllerPedido.pedidoVenda.valorComDesconto;
      _controllerPedido.editarItem(itemPedido, pedidoVenda.id, produto.id,
          pedidoVenda.converterParaMapa());
    }
    Navigator.of(context).pop(MaterialPageRoute(
        builder: (contexto) => TelaItensPedidovenda(pedidoVenda: pedidoVenda)));
  }
}
