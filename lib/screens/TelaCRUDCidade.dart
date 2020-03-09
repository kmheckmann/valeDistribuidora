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

  final DocumentSnapshot snapshot;
  final _controllerNome = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();

  Cidade cidade;
  bool _novocadastro;
  String _nomeTela;
  _TelaCRUDCidadeState(this.cidade, this.snapshot);

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
      cidade.ativa = true;
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
            //verifica se os campos estão validados antes de salvar
            if(_validadorCampos.currentState.validate()){
              Map<String, dynamic> mapa = cidade.converterParaMapa();
            if(_novocadastro){
              cidade.salvarCidade(mapa);
            }else{
              cidade.editarCidade(mapa, cidade.id);
            }
            Navigator.of(context).pop();
            }
          }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          //ListView para adicionar scroll quando abrir o teclado em vez de ocultar os campos
          children: <Widget>[
            TextFormField(
              controller: _controllerNome,
              decoration: InputDecoration(
                hintText: "Nome Cidade"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              keyboardType: TextInputType.text,
              validator: (text) {
                if(text.isEmpty) return "Informe o nome da cidade!";
              },
              onChanged: (texto) {
                cidade.nome = texto;
              },
            ),
            _criarCampoCheckBox()
          ],
        ))
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
