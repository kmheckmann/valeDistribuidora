import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/CidadeController.dart';
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
  final _scaffold = GlobalKey<ScaffoldState>();
  bool _existeCadastro;
  String _dropdownValue;

  Cidade cidade;
  CidadeController _controllerCidade = CidadeController();
  bool _novocadastro;
  String _nomeTela;
  _TelaCRUDCidadeState(this.cidade, this.snapshot);

  @override
  void initState() {
    super.initState();
    _existeCadastro = false;
    if (cidade != null) {
      _nomeTela = "Editar Cidade";
      _controllerNome.text = cidade.nome;
      _dropdownValue = cidade.estado;
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
        key: _scaffold,
        appBar: AppBar(
          title: Text(_nomeTela),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.blue,
            onPressed: () async {
              await _controllerCidade.verificarExistenciaCidade(cidade);
              _existeCadastro = _controllerCidade.existeCadastro;
              //verifica se os campos estão validados antes de salvar
              if (_validadorCampos.currentState.validate()) {
                if (_dropdownValue != null) {
                  //Ao savar é executada a validação do form é feita, caso exista uma cidade com mesmo nome
                  //ou o nome esteja vazio o cadastro não é realizado e é apresentada a mensagem
                  if (_existeCadastro) {
                    _scaffold.currentState.showSnackBar(SnackBar(
                      content: Text("Essa cidade já está cadastrada!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                    ));                    
                  } else {
                    Map<String, dynamic> mapa =
                        _controllerCidade.converterParaMapa(cidade);
                    if (_novocadastro) {
                      await _controllerCidade.obterProxID();
                      cidade.id = _controllerCidade.proxID;
                      _controllerCidade.salvarCidade(mapa, cidade.id);
                    } else {
                      _controllerCidade.editarCidade(mapa, cidade.id);
                    }
                    Navigator.of(context).pop();
                  }
                } else {
                  if (_dropdownValue == null) {
                    _scaffold.currentState.showSnackBar(SnackBar(
                      content: Text("É necessário selecionar um Estado!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                    ));
                  }
                }
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
                  decoration: InputDecoration(hintText: "Nome Cidade"),
                  style: TextStyle(color: Colors.black, fontSize: 17.0),
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    //no validator consiste se a cidade informada já existe
                    //se existir retorna a mensagem
                    if (text.isEmpty) return "Informe o nome da cidade!";
                  },
                  onChanged: (texto) {
                    cidade.nome = texto;
                  },
                ),
                _criarDropDownEstado(),
                _criarCampoCheckBox()
              ],
            )));
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

  Widget _criarDropDownEstado() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          DropdownButton<String>(
            value: _dropdownValue,
            style: TextStyle(color: Colors.black),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            hint: Text("Selecionar Estado"),
            onChanged: (String newValue) {
              setState(() {
                cidade.estado = null;
                _dropdownValue = newValue;
                cidade.estado = _dropdownValue;
              });
            },
            items: <String>[
              'Acre',
              'Alogoas',
              'Amapá',
              'Amazonas',
              'Bahia',
              'Ceará',
              'Distrito Federal',
              'Espírito Santo',
              'Goiás',
              'Maranhão',
              'Mato Grosso',
              'Mato Grosso do Sul',
              'Minas Gerais',
              'Pará',
              'Paraíba',
              'Paraná',
              'Pernambuco',
              'Piauí',
              'Rio de Janeiro',
              'Rio Grande do Norte',
              'Rio Grande do Sul',
              'Rondônia',
              'Roraima',
              'Santa Catarina',
              'São Paulo',
              'Sergipe',
              'Tocantins'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
