import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  String _nomeTela;
  Cidade cidade = Cidade();
  String _dropdownValue;
  bool _existeCadastro;

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
    _existeCadastro = false;
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
          onPressed: () {

            if(_validadorCampos.currentState.validate()){
              if(_dropdownValue != null && empresa.email.contains("@") && empresa.email.contains(".com")){
                Map<String, dynamic> mapa = empresa.converterParaMapa();
                Map<String, dynamic> mapaCidade = Map();
                mapaCidade["id"] = cidade.id;
                if(_novocadastro){
                  empresa.salvarEmpresa(mapa, mapaCidade);
                }else{
                  empresa.editarEmpresa(mapa, mapaCidade, empresa.id);
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
            _criarCampoText(_controllerRazaoSocial, "Razão Social", TextInputType.text, 200),
                _criarCampoText(
                    _controllerNomeFantasia, "Nome Fantasia", TextInputType.text, 200),
                _criarCampoText(
                    _controllerinscEstadual, "Inscrição Estadual", TextInputType.number, 9),
                _criarCampoText(
                    _controllerCnpj, "CNPJ", TextInputType.number, 14),
                _criarCampoText(
                    _controllerCep, "CEP", TextInputType.number, 8),
                _criarDropDownCidade(),
                _criarCampoText(
                    _controllerBairro, "Bairro", TextInputType.text, 100),
                _criarCampoText(
                    _controllerlogradouro, "Logradouro", TextInputType.text, 100),
                _criarCampoText(
                    _controllerNumero, "Número", TextInputType.number, 10),
                _criarCampoText(
                    _controllerTelefone, "Telefone", TextInputType.number, 11),
                _criarCampoText(
                    _controllerEmail, "E-mail", TextInputType.emailAddress, 50),
                _criarCampoCheckBox(),
                _criarCampoCheckBoxFornecedor(),
          ],
        )));
  }

  Widget _criarCampoText(
      TextEditingController controller, String nome, TextInputType tipo, int tamanho) {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: controller,
          keyboardType: tipo,
          maxLength: tamanho,
          decoration: InputDecoration(
            hintText: nome,
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
              if(text.isEmpty) return "É necessário informar este campo!";      
              if(_existeCadastro && text.isNotEmpty) return "Já existe empresa com essa IE, verifique!";
              },
          onChanged: (texto) {
            switch (nome) {
              case "Razão Social":
                empresa.razaoSocial = texto;
                _verificarExistenciaEmpresa();
                break;
              case "Nome Fantasia":
                empresa.nomeFantasia = texto;
                _verificarExistenciaEmpresa();
                break;
              case "CNPJ":
                empresa.cnpj = texto;
                _verificarExistenciaEmpresa();
                break;
              case "Inscrição Estadual":
                empresa.inscEstadual = texto;
                _verificarExistenciaEmpresa();
                break;
              case "CEP":
                empresa.cep = texto;
                _verificarExistenciaEmpresa();
                break;
              case "Bairro":
                empresa.bairro = texto;
                _verificarExistenciaEmpresa();
                break;
              case "Logradouro":
                empresa.logradouro = texto;
                _verificarExistenciaEmpresa();
                break;
              case "Número":
                empresa.numero = int.parse(texto);
                _verificarExistenciaEmpresa();
                break;
              case "Telefone":
                empresa.telefone = texto;
                _verificarExistenciaEmpresa();
                break;
              case "E-mail":
                empresa.email = texto;
                _verificarExistenciaEmpresa();
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

void _verificarExistenciaEmpresa() async {
    //Busca todas as empresas cadastradas
    CollectionReference ref = Firestore.instance.collection("empresas");
  //Nas empresas cadastradas verifica se existe alguma com o mesmo cnpj e IE do cadastro atual
  //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery = await ref
    .where("inscEstadual", isEqualTo: empresa.inscEstadual)
    .getDocuments();
    print(eventsQuery.documents.length);
    if(eventsQuery.documents.length > 0){
      _existeCadastro = true;
    }else{
      _existeCadastro = false;
    }
  }

}
