import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Cidade.dart';

class TelaCRUDCidade extends StatefulWidget {

  final Cidade cidade;
  final DocumentSnapshot snapshot;

  TelaCRUDCidade({this.cidade, this.snapshot});

  @override
  _TelaCRUDCidadeState createState() => _TelaCRUDCidadeState(cidade, snapshot);
}

class _TelaCRUDCidadeState extends State<TelaCRUDCidade> {

  Cidade cidade;
  final DocumentSnapshot snapshot;
  bool _novocadastro;

  _TelaCRUDCidadeState(this.cidade, this.snapshot);

  Cidade _cidadeEditada = Cidade();

  String _nomeTela;
  final _controllerNome = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (cidade != null) {
      _nomeTela = "Editar Cidade";
      _controllerNome.text = cidade.nome;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Cidade";
      cidade = Cidade();
      cidade.ativa = false;
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.blue,
          onPressed: () {
            Map<String, dynamic> mapa = cidade.converterParaMapa();
            if(_novocadastro){
              cidade.salvarCidade(mapa);
            }else{
              cidade.editarCidade(mapa, cidade.id);
            }
            Navigator.of(context).pop();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Nome Cidade"),
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                    onChanged: (texto) {
                      cidade.nome = texto;
                    },
                  ),
                ),
                _criarCampoCheckBox()
              ],
            )),
      ),
    );
  }


  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: cidade.ativa == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  cidade.ativa = true;
                } else {
                  cidade.ativa = false;
                }
              });
            },
          ),
          Text(
            "Ativa?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
