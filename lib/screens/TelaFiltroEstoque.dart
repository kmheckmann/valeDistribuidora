import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/EstoqueProdutoController.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/EstoqueProduto.dart';
import 'package:tcc_2/model/Produto.dart';
import 'package:tcc_2/screens/TelaEstoque.dart';

class TelaFiltroEstoque extends StatefulWidget {
  @override
  _TelaFiltroEstoqueState createState() => _TelaFiltroEstoqueState();
}

class _TelaFiltroEstoqueState extends State<TelaFiltroEstoque> {

EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
ProdutoController _controllerProduto = ProdutoController();
Produto p = Produto();
List<EstoqueProduto> estoques;
Stream<QuerySnapshot> _produtos;
String _dropdownValueProduto;

@override
  void initState() {
    super.initState();
    _produtos = Firestore.instance.collection("produtos").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async{
          await _controllerProduto.obterProdutoPorDescricao(_dropdownValueProduto);
          p = _controllerProduto.produto;
          await _controllerEstoque.obterEstoqueProduto(p);
          this.estoques = _controllerEstoque.estoques;
          Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaEstoque(estoques: estoques,))
            );

        }),
        body: Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 0, 3.0),
        child: _criarDropDownProduto(),),
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