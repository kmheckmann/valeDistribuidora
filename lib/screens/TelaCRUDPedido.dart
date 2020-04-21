import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaCRUDItemPedido.dart';
import 'package:tcc_2/screens/TelaItensPedido.dart';

class TelaCRUDPedido extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final DocumentSnapshot snapshot;
  final Usuario user;
  
  TelaCRUDPedido({this.pedidoVenda, this.snapshot, this.user});

  @override
  _TelaCRUDPedidoState createState() => _TelaCRUDPedidoState(pedidoVenda, snapshot, user);
}

class _TelaCRUDPedidoState extends State<TelaCRUDPedido> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  Usuario vendedor;

  _TelaCRUDPedidoState(this.pedidoVenda, this.snapshot, this.vendedor);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  Stream<QuerySnapshot> empresas;
  String _dropdownValueTipoPgto;
  String _dropdownValueCliente;
  String _dropdownValueTipoPedido;
  final _controllerVlTotal = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  bool _novocadastro;
  String _nomeTela;
  Empresa empresa = Empresa();
  

  @override
  void initState() {
    super.initState();
    empresas = Firestore.instance.collection('empresas').snapshots();
    if (pedidoVenda != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
      _controllerIdPedido.text = pedidoVenda.id;
      _controllerPercentDesc.text = pedidoVenda.percentualDesconto.toString();
      _controllerVendedor.text = pedidoVenda.user.nome;
      _dropdownValueTipoPgto = pedidoVenda.tipoPagamento;
      _dropdownValueTipoPedido = pedidoVenda.tipoPedido;
      _dropdownValueCliente = pedidoVenda.empresa.nomeFantasia;
      _novocadastro = false;
      //formatar data
      String data = (pedidoVenda.dataPedido.day.toString()+"/"+pedidoVenda.dataPedido.month.toString()+"/"+pedidoVenda.dataPedido.year.toString());
      _controllerData.text = data;
      
    } else {
      _nomeTela = "Novo Pedido";
      pedidoVenda = PedidoVenda();
      pedidoVenda.dataPedido = DateTime.now();
      pedidoVenda.ehPedidoVenda = true;
      pedidoVenda.pedidoFinalizado = false;
      pedidoVenda.valorTotal = 0.0;
      pedidoVenda.percentualDesconto = 0.0;
      //formatar data
      String data = (pedidoVenda.dataPedido.day.toString()+"/"+pedidoVenda.dataPedido.month.toString()+"/"+pedidoVenda.dataPedido.year.toString());
      _controllerData.text = data; 
      _novocadastro = true;
      _controllerVendedor.text = vendedor.nome;
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
            _obterVendedorDropDow();
          if(_dropdownValueTipoPgto != null &&
             _dropdownValueCliente != null &&
             _dropdownValueTipoPedido != null){
               Map<String, dynamic> mapa = pedidoVenda.converterParaMapa();
               print(vendedor.id);
               Map<String, dynamic> mapaVendedor = Map();
                mapaVendedor["id"] = vendedor.id;
                Map<String, dynamic> mapaEmpresa = Map();
                mapaEmpresa["id"] = empresa.id;
                if(_novocadastro){
                    pedidoVenda.salvarPedido(mapa, mapaEmpresa, mapaVendedor);
                  }else{
                    pedidoVenda.editarRota(mapa, mapaEmpresa, mapaVendedor, pedidoVenda.id);
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (contexto)=>TelaItensPedido(pedidoVenda: pedidoVenda)));
             }else{
               _scaffold.currentState.showSnackBar(
                SnackBar(content: Text("Todos os campos da tela devem ser informados!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),)
              );
             }
        }
      ),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _criarCampoTexto("Código Pedido", _controllerIdPedido),
            _criarCampoTexto("Vendedor", _controllerVendedor),
            _criarCampoTexto("Data Pedido", _controllerData),
            _criarDropDownTipoPedido(),
            _criarDropDownTipoPgto(),
            _criarDropDownCliente(),
            _criarCampoTexto("Valor Total", _controllerVlTotal),
            TextFormField(
              controller: _controllerPercentDesc,
              decoration: InputDecoration(
                hintText: "% Desconto"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              onChanged:(texto){
                pedidoVenda.percentualDesconto = double.parse(texto);
                pedidoVenda.calcularDesconto();
                setState(() {
                  _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
                });               
              },
            ),

          ],
          
        )),
    );
  }

Widget _criarCampoTexto(String nome, TextEditingController controller){
  return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: nome
          ),
          style: TextStyle(color: Colors.grey, fontSize: 17.0),
          enabled: false,
        );
}

Widget _criarDropDownTipoPedido(){
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0,0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 387.4,
            child: DropdownButton<String>(
            value: _dropdownValueTipoPedido,
            style: TextStyle(
            color: Colors.black
            ),
            hint: Text("Selecionar Tipo Pedido"),
            onChanged: (String newValue) {
              setState(() {
                _obterClienteDropDow();
                _dropdownValueTipoPedido = newValue;
                pedidoVenda.tipoPedido = newValue;
              });
            },
          items: <String>['Normal', 'Troca','Bonificação']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
          );
          })
          .toList(),
  ),
          )
        ],
      ),
    );
  }

Widget _criarDropDownTipoPgto(){
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0,0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 387.4,
            child: DropdownButton<String>(
            value: _dropdownValueTipoPgto,
            style: TextStyle(
            color: Colors.black
            ),
            hint: Text("Selecionar Tipo Pagamento"),
            onChanged: (String newValue) {
              setState(() {
                _obterClienteDropDow();
                _dropdownValueTipoPgto = newValue;
                pedidoVenda.tipoPagamento = _dropdownValueTipoPgto;
              });
            },
          items: <String>['À Vista', 'Cheque','Boleto', 'Duplicata']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
          );
          })
          .toList(),
  ),
          )
        ],
      ),
    );
  }

  Widget _criarDropDownCliente(){
   return StreamBuilder<QuerySnapshot>(
    stream: empresas,
    builder: (context, snapshot){
      var length = snapshot.data.documents.length;
      DocumentSnapshot ds = snapshot.data.documents[length - 1];
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0,0.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 387.4,
                child: DropdownButton(
                  value: _dropdownValueCliente,
                  hint: Text("Selecionar cliente"),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValueCliente = newValue;
                      _obterClienteDropDow();
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
  empresa = c;
  });
  return empresa;
}

Future<Usuario> _obterVendedorDropDow() async {
CollectionReference ref = Firestore.instance.collection('usuarios');
QuerySnapshot eventsQuery = await ref
    .where("cpf", isEqualTo: vendedor.cpf)
    .getDocuments();

eventsQuery.documents.forEach((document) {
  Usuario v = Usuario.buscarFirebase(document);
  vendedor = v;
});

return vendedor;
}

}