import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Produto.dart';

class TelaCRUDItemPedido extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaCRUDItemPedido({this.pedidoVenda, this.itemPedido, this.snapshot});

  @override
  _TelaCRUDItemPedidoState createState() => _TelaCRUDItemPedidoState(pedidoVenda, itemPedido, snapshot);
}

class _TelaCRUDItemPedidoState extends State<TelaCRUDItemPedido> {
  final DocumentSnapshot snapshot;
  ItemPedido itemPedido;
  PedidoVenda pedidoVenda;
  String _dropdownValueProduto;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  bool _novocadastro;
  String _nomeTela;
  Produto produto = Produto();

  _TelaCRUDItemPedidoState(this.pedidoVenda, this.itemPedido, this.snapshot);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (itemPedido != null) {
      _nomeTela = "Editar Produto";
      _dropdownValueProduto = itemPedido.produto.descricao;
      _controllerPreco.text = itemPedido.preco.toString();
      _controllerQtde.text = itemPedido.quantidade.toString();
      _novocadastro = false;
      
    } else {
      _nomeTela = "Novo Produto";
      print(pedidoVenda.id);
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.blue,
        onPressed: (){
          _obterProdutoDropDow();
          if(_validadorCampos.currentState.validate()){
            if(_dropdownValueProduto != null){
              print(produto.id);
              print(produto.descricao);
              Map<String, dynamic> mapa = itemPedido.converterParaMapa();
              if(_novocadastro){
                itemPedido.salvarItemPedido(mapa, pedidoVenda.id);
              }else{
                itemPedido.editarItemPedido(mapa, pedidoVenda.id, itemPedido.id);
              }
              Navigator.of(context).pop(pedidoVenda);
            }
            _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("É necessário selecionar um produto!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
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
    stream: Firestore.instance.collection("produtos").snapshots(),
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
                    _dropdownValueProduto = newValue;
                      _obterProdutoDropDow();
                    setState(() {
                     // _controllerPreco.text = produto.percentualLucro.toString();
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

Future<Produto> _obterProdutoDropDow() async {
  CollectionReference ref = Firestore.instance.collection('produtos');
  print(_dropdownValueProduto);
  QuerySnapshot eventsQuery = await ref
    .where("descricao", isEqualTo: _dropdownValueProduto)
    .getDocuments();
    print(eventsQuery.documents.length);
  eventsQuery.documents.forEach((document) {
  Produto p = Produto.buscarFirebase(document);
  itemPedido.preco = p.percentualLucro;
  p.id = document.documentID;
  produto = p;
  });
  return produto;
}
}