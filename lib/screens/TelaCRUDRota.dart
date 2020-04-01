import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Rota.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/Usuario.dart';

class TelaCRUDRota extends StatefulWidget {
  final Rota rota;
  final DocumentSnapshot snapshot;

  TelaCRUDRota({this.rota, this.snapshot});

  @override
  _TelaCRUDRotaState createState() => _TelaCRUDRotaState(rota, snapshot);
}
enum SingingCharacter { semanal, quinzenal, mensal }

class _TelaCRUDRotaState extends State<TelaCRUDRota> {
  final DocumentSnapshot snapshot;
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  Stream<QuerySnapshot> empresas;
  Stream<QuerySnapshot> vendedores;
  bool _clienteComRota;
  String _dropdownValueVendedor;
  String _dropdownValueCliente;
  String _dropdownValueDiaSemana;

  Rota rota;
  bool _novocadastro;
  String _nomeTela;
  Empresa cliente = Empresa();
  Usuario vendedor = Usuario();

  
  SingingCharacter _character = SingingCharacter.semanal;
  _TelaCRUDRotaState(this.rota, this.snapshot);
  @override
  void initState() {
    super.initState();
    empresas = Firestore.instance.collection('empresas').snapshots();
    vendedores = Firestore.instance.collection('usuarios').snapshots();
    _clienteComRota = false;
    if (rota != null) {
      _nomeTela = "Editar Rota";
      _dropdownValueDiaSemana = rota.diaSemana;
      _dropdownValueVendedor = rota.vendedor.nome;
      _dropdownValueCliente = rota.cliente.nomeFantasia;
      _atribuirValorFrquencia(rota.frequencia);
      _novocadastro = false;
      
    } else {
      _nomeTela = "Cadastrar Rota";
      rota = Rota();
      rota.ativa = true;
      _novocadastro = true;
      rota.frequencia = "Semanal";
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
          _verificarExistenciaRota();
          print(_clienteComRota);
          if(_dropdownValueCliente != null 
          && _dropdownValueVendedor != null 
          && _dropdownValueDiaSemana != null){  
              if(_clienteComRota == false){
                rota.tituloRota = _dropdownValueVendedor+" - "+_dropdownValueCliente;         
                Map<String, dynamic> mapa = rota.converterParaMapa();
                Map<String, dynamic> mapaVendedor = Map();
                mapaVendedor["id"] = vendedor.id;
                Map<String, dynamic> mapaCliente = Map();
                mapaCliente["id"] = cliente.id;
                  if(_novocadastro){
                    String id = (_dropdownValueVendedor+" - "+_dropdownValueCliente);
                    rota.salvarRota(mapa, mapaCliente,mapaVendedor, id);
                  }else{
                    rota.editarRota(mapa, mapaCliente, mapaVendedor, rota.idFirebase);
                  }
                  Navigator.of(context).pop();

              }else{
                _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("Cliente é utilizado em outra rota. Verifique!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
              }
          }else{
            _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("Todos os campos da tela devem ter um valor selecionado!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
          }
        },
      ),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _criarDropDownVendedor(),
            _criarDropDownCliente(),
            _criarDropDownDiaSemana(),
            _criarRadioButton(),
            _criarCampoCheckBox(),

          ],
        )),
    );
  }

  Widget _criarDropDownCliente(){
   return StreamBuilder<QuerySnapshot>(
    stream: empresas,
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
                  value: _dropdownValueCliente,
                  hint: Text("Selecionar cliente"),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValueCliente = newValue;
                      _obterClienteDropDow();
                      _obterVendedorDropDow();
                      _verificarExistenciaRota();
                    });
                  },
                  items: snapshot.data.documents.map((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                        value: document.data['nomeFantasia'],
                        child: Container(
                          child:Text(document.data['nomeFantasia'],style: TextStyle(color: Colors.black)),
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

Future<Empresa> _obterClienteDropDow() async {
CollectionReference ref = Firestore.instance.collection('empresas');
QuerySnapshot eventsQuery = await ref
    .where("nomeFantasia", isEqualTo: _dropdownValueCliente)
    .getDocuments();

eventsQuery.documents.forEach((document) {
  Empresa c = Empresa.buscarFirebase(document);
  cliente = c;
});

return cliente;
}

  Widget _criarDropDownVendedor(){
   return StreamBuilder<QuerySnapshot>(
    stream: vendedores,
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
                  value: _dropdownValueVendedor,
                  hint: Text("Selecionar vendedor"),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValueVendedor = newValue;
                      _obterVendedorDropDow();
                      _obterClienteDropDow();
                      _verificarExistenciaRota();
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

  Future<Usuario> _obterVendedorDropDow() async {
CollectionReference ref = Firestore.instance.collection('usuarios');
QuerySnapshot eventsQuery = await ref
    .where("nome", isEqualTo: _dropdownValueVendedor)
    .getDocuments();

eventsQuery.documents.forEach((document) {
  Usuario v = Usuario.buscarFirebase(document);
  vendedor = v;
});

return vendedor;
}

Widget _criarDropDownDiaSemana(){
    return Container(
      width: 300.0,
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 300.0,
            child: DropdownButton<String>(
    value: _dropdownValueDiaSemana,
    style: TextStyle(
      color: Colors.black
    ),
    hint: Text("Selecionar dia semana"),
    onChanged: (String newValue) {
      setState(() {
        _dropdownValueDiaSemana = newValue;
        rota.diaSemana = _dropdownValueDiaSemana;
        _obterClienteDropDow();
        _obterVendedorDropDow();
        _verificarExistenciaRota();
      });
    },
    items: <String>['Domingo', 'Segunda-feira','Terça-feita',
                    'Quarta-feira','Quinta-feira','Sexta-feira','Sábado']
      .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,style: TextStyle(color: Colors.black)),
        );
      })
      .toList(),
  ),
          )
        ],
      ),
    );
  }

Widget _criarRadioButton(){
  return Column(
    children: <Widget>[
      RadioListTile<SingingCharacter>(
        title: const Text('Semanal'),
        value: SingingCharacter.semanal,
        groupValue: _character,
        onChanged: (SingingCharacter value) { 
          setState(() {
             _character = value; 
             rota.frequencia = "Semanal";
             _obterClienteDropDow();
             _obterVendedorDropDow();
             _verificarExistenciaRota();
             
             }
          ); },
      ),
      RadioListTile<SingingCharacter>(
        title: const Text('Quinzenal'),
        value: SingingCharacter.quinzenal,
        groupValue: _character,
        onChanged: (SingingCharacter value) { 
          setState(() { 
            _character = value; 
            rota.frequencia = "Quinzenal";
            _obterClienteDropDow();
            _obterVendedorDropDow();
            _verificarExistenciaRota();
            }); },
      ),
      RadioListTile<SingingCharacter>(
        title: const Text('Mensal'),
        value: SingingCharacter.mensal,
        groupValue: _character,
        onChanged: (SingingCharacter value) { 
          setState(() { 
            _character = value; 
            rota.frequencia = "Mensal";
            _obterClienteDropDow();
            _obterVendedorDropDow();
            _verificarExistenciaRota();
            }); },
      )
    ],
  );
}

Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: rota.ativa == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  rota.ativa = true;
                } else {
                  rota.ativa = false;
                }
                _obterClienteDropDow();
                _obterVendedorDropDow();
                _verificarExistenciaRota();
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
  void _atribuirValorFrquencia(String frequencia){
    if(frequencia == "Semanal"){
      _character = SingingCharacter.semanal;
    }
    if(frequencia == "Quinzenal"){
      _character = SingingCharacter.quinzenal;
    }
    if(frequencia == "Mensal"){
      _character = SingingCharacter.mensal;
    }
  }

  void _verificarExistenciaRota() async {
    //Busca todas as rotas cadastradas
    CollectionReference ref = Firestore.instance.collection("rotas");
    QuerySnapshot eventsQuery1 = await ref.where("ativa", isEqualTo: true).getDocuments();
    print(eventsQuery1.documents.length);
      if(eventsQuery1.documents.length > 0){
        eventsQuery1.documents.forEach((document) async {
          CollectionReference ref2 = Firestore.instance.collection('rotas').document(document.documentID).collection('cliente');
          QuerySnapshot eventsQuery2 = await ref2.where("id", isEqualTo: cliente.id).getDocuments();
          eventsQuery2.documents.forEach((document1){
            if(document1["id"] == cliente.id){
              _clienteComRota = true;
            }else{
              _clienteComRota = false;
            }
          });
        });
      }else{
        _clienteComRota = false;
      }
  }
}