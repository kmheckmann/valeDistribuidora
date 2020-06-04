import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/CategoriaController.dart';
import 'package:tcc_2/model/Categoria.dart';

class TelaCRUDCategoria extends StatefulWidget {

  final Categoria categoria;
  DocumentSnapshot snapshot;

  TelaCRUDCategoria({this.categoria, this.snapshot});
  @override
  _TelaCRUDCategoriaState createState() => _TelaCRUDCategoriaState(categoria,snapshot);
}

class _TelaCRUDCategoriaState extends State<TelaCRUDCategoria> {
  Categoria categoria;
  final DocumentSnapshot snapshot;

  _TelaCRUDCategoriaState(this.categoria, this.snapshot);

  final _controllerDescricao = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  CategoriaController controllerCategoria = CategoriaController();
  bool _existeCadastro;
  bool _novocadastro;
  String _nomeTela;

  @override
  void initState() {
    super.initState();
    _existeCadastro = false;
    if (categoria != null) {
      _nomeTela = "Editar Categoria";
      _controllerDescricao.text = categoria.descricao;
      _novocadastro = false;
      
    } else {
      _nomeTela = "Cadastrar Categoria";
      categoria = Categoria();
      categoria.ativa = true;
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
          if(_validadorCampos.currentState.validate()){

            Map<String, dynamic> mapa = controllerCategoria.converterParaMapa(categoria);

            if(_novocadastro){
              await controllerCategoria.obterProxID();
              categoria.id = controllerCategoria.proxID;
              print(categoria.id);
              controllerCategoria.salvarCategoaria(mapa,categoria.id);
            }else{

              controllerCategoria.editarCategoria(mapa, categoria.id);
            }

            Navigator.of(context).pop();
          }

        }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            TextFormField(
              controller: _controllerDescricao,
              decoration: InputDecoration(
                hintText: "Descrição da categoria"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              keyboardType: TextInputType.text,
              validator: (text){
                //verifica se o campo está preenchidoe se a categoria já existe, se sim, retorna mensagem
                if(_existeCadastro) return "Categoria já existe. Verifique!";
                if(text.isEmpty) return "Informe a descrição!";
              },
              onChanged: (text) async{
                categoria.descricao = text;
                await controllerCategoria.verificarExistenciaCategoria(categoria.descricao);
                _existeCadastro = controllerCategoria.existeCadastro;
              },
            ),
            _criarCampoCheckBox()
          ],
        )),
    );
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: categoria.ativa == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  categoria.ativa = true;
                } else {
                  categoria.ativa = false;
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