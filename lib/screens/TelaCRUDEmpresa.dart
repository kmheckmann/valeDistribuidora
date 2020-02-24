import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Cidade.dart';
import 'package:tcc_2/model/Empresa.dart';

class TelaCRUDEmpresa extends StatefulWidget {


  final Empresa empresa;
  final DocumentSnapshot snapshot;

  TelaCRUDEmpresa({this.empresa, this.snapshot});


  @override
  _TelaCRUDEmpresaState createState() => _TelaCRUDEmpresaState(empresa, snapshot);
}

class _TelaCRUDEmpresaState extends State<TelaCRUDEmpresa> {

  Empresa empresa;
  final DocumentSnapshot snapshot;
  bool _novocadastro;
  List cidades = [];

  _TelaCRUDEmpresaState(this.empresa, this.snapshot);

  Empresa _empresaEditada = Empresa();
  String _nomeTela;
  Cidade cidade = Cidade();

  final _controllerRazaoSocial = TextEditingController();
  final _controllerNomeFantasia = TextEditingController();
  final _controllerCnpj = TextEditingController();
  final _controllerinscEstadual = TextEditingController();
  final _controllerCep = TextEditingController();
  final _controllerBairro = TextEditingController();
  final _controllerlogradouro = TextEditingController();
  final _controllerNumero = TextEditingController();
  final _controllerTelefone = TextEditingController();
  final _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (empresa != null) {
      _nomeTela = "Editar Empresa";
      _controllerRazaoSocial.text = empresa.razaoSocial;
      _controllerNomeFantasia.text = empresa.nomeFantasia;
      _controllerCnpj.text = empresa.cnpj;
      _controllerinscEstadual.text = empresa.inscEstadual;
      _controllerCep.text = empresa.cep;
      _controllerBairro.text = empresa.bairro;
      _controllerlogradouro.text = empresa.logradouro;
      _controllerNumero.text = empresa.numero.toString();
      _controllerTelefone.text = empresa.telefone;
      _controllerEmail.text = empresa.email;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Empresa";
      empresa = Empresa();
      empresa.ativo = false;
      empresa.ehFornecedor = false;
      _novocadastro = true;
    }
  }

String _dropdownValue;
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
            Map<String, dynamic> mapa = empresa.converterParaMapa();
            Map<String, dynamic> mapaCidade = cidade.converterParaMapa();
            if(_novocadastro){
              empresa.salvarEmpresa(mapa, mapaCidade);
            }else{
              empresa.editarEmpresa(mapa, mapaCidade, empresa.id, cidade.id);
            }
            Navigator.of(context).pop();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Container(
            child: Column(
              children: <Widget>[
                _criarCampoText(_controllerRazaoSocial, "Razão Social", TextInputType.text),
                _criarCampoText(
                    _controllerNomeFantasia, "Nome Fantasia", TextInputType.text),
                _criarCampoText(
                    _controllerinscEstadual, "Inscrição Estadual", TextInputType.text),
                _criarCampoText(
                    _controllerCnpj, "CNPJ", TextInputType.text),
                _criarCampoText(
                    _controllerCep, "CEP", TextInputType.text),
                _criarDropDownCidade(),
                _criarCampoText(
                    _controllerBairro, "Bairro", TextInputType.text),
                _criarCampoText(
                    _controllerlogradouro, "Logradouro", TextInputType.text),
                _criarCampoText(
                    _controllerNumero, "Número", TextInputType.number),
                _criarCampoText(
                    _controllerTelefone, "Telefone", TextInputType.text),
                _criarCampoText(
                    _controllerEmail, "E-mail", TextInputType.emailAddress),
                _criarCampoCheckBox(),
                _criarCampoCheckBoxFornecedor(),
                
              ],
            )),
      ),
    );
  }


  Widget _criarCampoText(
      TextEditingController controller, String nome, TextInputType tipo) {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextField(
          controller: controller,
          keyboardType: tipo,
          decoration: InputDecoration(
            labelText: nome,
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          onChanged: (texto) {
            switch (nome) {
              case "Razão Social":
                empresa.razaoSocial = texto;
                break;
              case "Nome Fantasia":
                empresa.nomeFantasia = texto;
                break;
              case "CNPJ":
                empresa.cnpj = texto;
                break;
              case "Inscrição Estadual":
                empresa.inscEstadual = texto;
                break;
              case "CEP":
                empresa.cep = texto;
                break;
              case "Bairro":
                empresa.bairro = texto;
                break;
              case "Logradouro":
                empresa.logradouro = texto;
                break;
              case "Número":
                empresa.numero = int.parse(texto);
                break;
              case "Telefone":
                empresa.telefone = texto;
                break;
              case "E-mail":
                empresa.email = texto;
                break;
            }
          },
        ));
  }


  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: empresa.ativo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.ativo = true;
                } else {
                  empresa.ativo = false;
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

  Widget _criarCampoCheckBoxFornecedor() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: empresa.ehFornecedor == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.ehFornecedor = true;
                } else {
                  empresa.ehFornecedor = false;
                }
              });
            },
          ),
          Text(
            "Fornecedor?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarDropDownCidade(){
   return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection('cidades').snapshots(),
    builder: (context, snapshot){
      var length = snapshot.data.documents.length;
      DocumentSnapshot ds = snapshot.data.documents[length - 1];
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 300.0,
                child: DropdownButton(
                  value: _dropdownValue,
                  hint: Text("Selecionar cidade"),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValue = newValue;
                      _obterCidadeDropDow();
                      print(cidade.nome);
                    });
                  },
                  items: snapshot.data.documents.map((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                        value: document.data['nome'],
                        child: Container(
                          child:Text(document.data['nome'],style: TextStyle(color: Colors.black)),
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

Future<Cidade> _obterCidadeDropDow() async {
CollectionReference ref = Firestore.instance.collection('cidades');
QuerySnapshot eventsQuery = await ref
    .where("nome", isEqualTo: _dropdownValue)
    .getDocuments();

eventsQuery.documents.forEach((document) {
  cidade.id = document.documentID;
  cidade.nome = document.data["nome"];
  cidade.ativa = document.data["ativa"];
});

return cidade;
}

}
