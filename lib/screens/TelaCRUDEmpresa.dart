import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/EmpresaController.dart';
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

  _TelaCRUDEmpresaState(this.empresa, this.snapshot);

  String _nomeTela;
  Cidade cidade = Cidade();
  EmpresaController _controllerEmpresa = EmpresaController();
  String _dropdownValue;
  bool _existeCadastroIE;
  bool _existeCadastroCNPJ;
  Stream<QuerySnapshot> _streamCidade;

  final _scaffold = GlobalKey<ScaffoldState>();
  final _validadorCampos = GlobalKey<FormState>();
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
    _existeCadastroIE = false;
    _existeCadastroCNPJ = false;
    _streamCidade = Firestore.instance.collection('cidades').snapshots();
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
      _dropdownValue = empresa.cidade.nome;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Empresa";
      empresa = Empresa();
      empresa.ativo = true;
      empresa.ehFornecedor = true;
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
            _controllerEmpresa.verificarExistenciaEmpresa(empresa);
            _existeCadastroCNPJ = _controllerEmpresa.existeCadastroCNPJ;           
            _existeCadastroIE = _controllerEmpresa.existeCadastroIE;

            if(_validadorCampos.currentState.validate()){
              if(_dropdownValue != null && empresa.email.contains("@") && empresa.email.contains(".com")){
                Map<String, dynamic> mapa = _controllerEmpresa.converterParaMapa(empresa);
                Map<String, dynamic> mapaCidade = Map();
                mapaCidade["id"] = cidade.id;
                if(_novocadastro){
                  _controllerEmpresa.salvarEmpresa(mapa, mapaCidade);
                }else{
                  _controllerEmpresa.editarEmpresa(mapa, mapaCidade, empresa.id);
              }
            Navigator.of(context).pop();
            }else{
                if(!empresa.email.contains("@") || !empresa.email.contains(".com")){
                _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("E-mail inválido!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
              }
              if(_dropdownValue == null){
                _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("É necessário selecionar uma cidade!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
              }
              
            }
              }
          }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _criarCampoRazaoSocial(),
                _criarCampoNomFantasia(),
                _criarCampoIE(),
                _criarCampoCNPJ(),
                _criarCampoCEP(),
                _criarDropDownCidade(),
                _criarCampoBairro(),
                _criarCampoLogradouro(),
                _criarCampoNumero(),
                _criarCampoTelefone(),
                _criarCampoEmail(),
                _criarCampoCheckBox(),
                _criarCampoCheckBoxFornecedor(),
          ],
        )));
  }

  
Widget _criarCampoRazaoSocial(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerRazaoSocial,
          keyboardType: TextInputType.text,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: "Razão Social",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";      
              },
          onChanged: (texto) {
                empresa.razaoSocial = texto;
          },
        ));
  }

Widget _criarCampoNomFantasia(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerNomeFantasia,
          keyboardType: TextInputType.text,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: "Nome Fantasia",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar  este campo!";  
              },
          onChanged: (texto) {
                empresa.nomeFantasia = texto;
          },
        ));
  }

  Widget _criarCampoCEP(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerCep,
          keyboardType: TextInputType.number,
          maxLength: 8,
          decoration: InputDecoration(
            hintText: "CEP",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty || text.length < 8) return "É necessário informar corretamente este campo!";  
              },
          onChanged: (texto) {
                empresa.cep = texto;
          },
        ));
  }

  Widget _criarCampoEmail(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerEmail,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: "E-mail",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";  
              if(text.isNotEmpty && !text.contains("@") || !text.contains(".com")) return "E-mail inválido!";
              },
          onChanged: (texto) {
                empresa.email = texto;
          },
        ));
  }

  Widget _criarCampoNumero(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerNumero,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: "Número",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";  
              },
          onChanged: (texto) {
                empresa.numero = int.parse(texto);
          },
        ));
  }

  Widget _criarCampoTelefone(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerTelefone,
          keyboardType: TextInputType.number,
          maxLength: 11,
          decoration: InputDecoration(
            hintText: "Telefone",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";  
              },
          onChanged: (texto) {
                empresa.telefone = texto;
          },
        ));
  }

  Widget _criarCampoBairro(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerBairro,
          keyboardType: TextInputType.text,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: "Bairro",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";  
              },
          onChanged: (texto) {
                empresa.bairro = texto;
          },
        ));
  }

  Widget _criarCampoLogradouro(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerlogradouro,
          keyboardType: TextInputType.text,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: "Logradouro",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";  
              },
          onChanged: (texto) {
                empresa.logradouro = texto;
          },
        ));
  }

Widget _criarCampoCNPJ(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerCnpj,
          keyboardType: TextInputType.number,
          maxLength: 14,
          decoration: InputDecoration(
            hintText: "CNPJ",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty || text.length < 14) return "É necessário informar corretamente este campo!";  
              if(_existeCadastroCNPJ && text.isNotEmpty) return "Já existe empresa com esse CNPJ, verifique!";
              },
          onChanged: (texto) {
                empresa.cnpj = texto;
          },
        ));
  }
  Widget _criarCampoIE(){
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerinscEstadual,
          keyboardType: TextInputType.number,
          maxLength: 9,
          decoration: InputDecoration(
            hintText: "Inscrição Estadual",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty || text.length < 9) return "É necessário informar corretamente este campo!";  
              if(_existeCadastroIE && text.isNotEmpty) return "Já existe empresa com essa IE, verifique!";    
              },
          onChanged: (texto) {
                empresa.inscEstadual = texto;
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
    stream: _streamCidade,
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
