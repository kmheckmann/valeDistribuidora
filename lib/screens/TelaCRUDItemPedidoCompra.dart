import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/ItemPedidoController.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/Produto.dart';
import 'package:tcc_2/screens/TelaItensPedidoCompra.dart';

class TelaCRUDItemPedidoCompra extends StatefulWidget {
  final PedidoCompra pedidoCompra;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaCRUDItemPedidoCompra({this.pedidoCompra, this.itemPedido, this.snapshot});

  @override
  _TelaCRUDItemPedidoCompraState createState() => _TelaCRUDItemPedidoCompraState(snapshot: snapshot, pedidoCompra: pedidoCompra, itemPedido: itemPedido);
}

class _TelaCRUDItemPedidoCompraState extends State<TelaCRUDItemPedidoCompra> {
  final DocumentSnapshot snapshot;
  PedidoCompra pedidoCompra;
  ItemPedido itemPedido;

  _TelaCRUDItemPedidoCompraState({this.snapshot, this.pedidoCompra, this.itemPedido});

  String _dropdownValueProduto;
  double vlItemAntigo;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  bool _novocadastro;
  String _nomeTela;
  Produto produto = Produto();
  Stream<QuerySnapshot> _produtos;

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  ProdutoController _controllerProduto = ProdutoController();
  ItemPedidoController _controllerItemPedido = ItemPedidoController();
  PedidoController _controllerPedido = PedidoController();

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
      itemPedido = ItemPedido(pedidoCompra);
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.blue,
        onPressed: () async{
          await _controllerProduto.obterProdutoPorDescricao(_dropdownValueProduto);
          produto = _controllerProduto.produto;
          
          if(_validadorCampos.currentState.validate()){
            if(_dropdownValueProduto != null){
              if(_novocadastro){
                await _controllerItemPedido.obterProxID(pedidoCompra.id);
                itemPedido.id = _controllerItemPedido.proxID;
                _controllerPedido.somarPrecoNoVlTotal(pedidoCompra, itemPedido);
                pedidoCompra.valorTotal = _controllerPedido.pedidoCompra.valorTotal;
                pedidoCompra.valorComDesconto = _controllerPedido.pedidoCompra.valorComDesconto;
                _controllerPedido.adicionarItem(itemPedido, pedidoCompra.id, produto.id, _controllerPedido.converterParaMapa(pedidoCompra));
              }else{
                _controllerPedido.atualizarPrecoNoVlTotal(vlItemAntigo, pedidoCompra, itemPedido);
                pedidoCompra.valorTotal = _controllerPedido.pedidoCompra.valorTotal;
                pedidoCompra.valorComDesconto = _controllerPedido.pedidoCompra.valorComDesconto;
                _controllerPedido.editarItem(itemPedido, pedidoCompra.id, produto.id, _controllerPedido.converterParaMapa(pedidoCompra));
              }
              Navigator.of(context).pop(MaterialPageRoute(builder: (contexto)=>TelaItensPedidoCompra(pedidoCompra: pedidoCompra)));
            }else{
              _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("É necessário selecionar um produto!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
            }
          }
        }),
        body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _criarDropDownProduto(),
              TextFormField(
                controller: _controllerPreco,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                hintText: "Preço"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              validator: (text){
                if(_controllerPreco.text.isEmpty) return "É necessário preencher este campo!";
              },
              onChanged: (texto){
                itemPedido.preco = double.parse(texto);
              },
              ),
              TextFormField(
                controller: _controllerQtde,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                hintText: "Quantidade"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              validator: (texto){
                if(_controllerQtde.text.isEmpty) return "É necessário preencher este campo!";
              },
              onChanged: (texto){
                itemPedido.quantidade = int.parse(texto);
              },
              ),

            ],
          )),
    );
  }

  Widget _criarDropDownProduto(){
   return StreamBuilder<QuerySnapshot>(
    stream: _produtos,
    builder: (context, snapshot){
      var length = snapshot.data.documents.length;
      DocumentSnapshot ds = snapshot.data.documents[length - 1];
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0,0.0),
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
                  items: snapshot.data.documents.map((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                        value: document.data['descricao'],
                        child: Container(
                          child:Text(document.data['descricao'],style: TextStyle(color: Colors.black)),
                        )
                    );
                  }).toList(),
                ),
            ),
          ],
        ),
      );
    }
);
  }

  }