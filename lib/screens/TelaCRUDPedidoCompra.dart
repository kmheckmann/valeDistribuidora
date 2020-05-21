import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/EmpresaController.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/controller/UsuarioController.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaItensPedidoCompra.dart';
import 'package:intl/intl.dart';

class TelaCRUDPedidoCompra extends StatefulWidget {

  final PedidoCompra pedidoCompra;
  final DocumentSnapshot snapshot;
  final Usuario vendedor;

  TelaCRUDPedidoCompra({this.pedidoCompra, this.snapshot, this.vendedor});

  @override
  _TelaCRUDPedidoCompraState createState() => _TelaCRUDPedidoCompraState(this.pedidoCompra, this.snapshot, this.vendedor);
}

class _TelaCRUDPedidoCompraState extends State<TelaCRUDPedidoCompra> {

  final DocumentSnapshot snapshot;
  PedidoCompra pedidoCompra;
  Usuario vendedor;

  _TelaCRUDPedidoCompraState(this.pedidoCompra, this.snapshot, this.vendedor);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  Stream<QuerySnapshot> empresas;
  String _dropdownValueTipoPgto;
  String _dropdownValueCliente;
  final _controllerVlTotal = TextEditingController();
  final _controllerVlTotalDesc = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  bool _novocadastro;
  String _nomeTela;
  Empresa empresa = Empresa();
  PedidoController _controllerPedido = PedidoController();
  EmpresaController _controllerEmpresa = EmpresaController();
  UsuarioController _controllerUsuario = UsuarioController();

  @override
  void initState() {
    super.initState();
    if (pedidoCompra != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoCompra.valorTotal.toString();
      _controllerIdPedido.text = pedidoCompra.id;
      _controllerPercentDesc.text = pedidoCompra.percentualDesconto.toString();
      _controllerVendedor.text = pedidoCompra.user.nome;
      _dropdownValueTipoPgto = pedidoCompra.tipoPagamento;
      _dropdownValueCliente = pedidoCompra.empresa.nomeFantasia;
      _controllerVlTotalDesc.text = pedidoCompra.valorComDesconto.toString();
      _novocadastro = false;
      //formatar data
      String data = (pedidoCompra.dataPedido.day.toString()+"/"+pedidoCompra.dataPedido.month.toString()+"/"+pedidoCompra.dataPedido.year.toString()+" "+(new DateFormat.Hms().format(pedidoCompra.dataPedido)));
      _controllerData.text = data;
      
    } else {
      _nomeTela = "Novo Pedido";
      pedidoCompra = PedidoCompra();
      pedidoCompra.dataPedido = DateTime.now();
      pedidoCompra.ehPedidoVenda = false;
      pedidoCompra.pedidoFinalizado = false;
      pedidoCompra.valorTotal = 0.0;
      pedidoCompra.percentualDesconto = 0.0;
      //formatar data
      String data = (pedidoCompra.dataPedido.day.toString()+"/"+pedidoCompra.dataPedido.month.toString()+"/"+pedidoCompra.dataPedido.year.toString()+" "+(new DateFormat.Hms().format(pedidoCompra.dataPedido)));
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
        child: Icon(Icons.apps),
        backgroundColor: Colors.blue,
        onPressed: () async{
            await _controllerEmpresa.obterEmpresaPorDescricao(_dropdownValueCliente);
            empresa = _controllerEmpresa.empresa;
            await _controllerUsuario.obterUsuarioPorCPF(vendedor.cpf);
            vendedor = _controllerUsuario.usuario;
          if(_dropdownValueTipoPgto != null &&
             _dropdownValueCliente != null){
               
               Map<String, dynamic> mapa = _controllerPedido.converterParaMapa(pedidoCompra);
               print(vendedor.id);
               Map<String, dynamic> mapaVendedor = Map();
                mapaVendedor["id"] = vendedor.id;
                Map<String, dynamic> mapaEmpresa = Map();
                mapaEmpresa["id"] = empresa.id;

                if(_novocadastro){
                  await _controllerPedido.obterProxID();
                  pedidoCompra.id = _controllerPedido.proxID;
                    _controllerPedido.salvarPedido(mapa, mapaEmpresa, mapaVendedor, pedidoCompra.id);
                  }else{
                    _controllerPedido.editarPedido(mapa, mapaEmpresa, mapaVendedor, pedidoCompra.id);
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (contexto)=>TelaItensPedidoCompra(pedidoCompra: pedidoCompra, snapshot: snapshot,)));
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
            _criarCampoTexto("Código Pedido", _controllerIdPedido, TextInputType.number),
            _criarCampoTexto("Vendedor", _controllerVendedor, TextInputType.text),
            _criarCampoTexto("Data Pedido", _controllerData, TextInputType.text),
            _criarDropDownTipoPgto(),
            _criarDropDownFornecedor(),
            _criarCampoTexto("Valor Total", _controllerVlTotal, TextInputType.number),
            _criarCampoTexto("Valor Total Com Desconto", _controllerVlTotalDesc, TextInputType.number),
            TextFormField(
              controller: _controllerPercentDesc,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "% Desconto"
              ),
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              onChanged:(texto){
                pedidoCompra.percentualDesconto = double.parse(texto);
                setState(() {
                  _controllerPedido.calcularDesconto(pedidoCompra);
                  pedidoCompra.valorComDesconto = _controllerPedido.pedidoCompra.valorComDesconto;
                  _controllerVlTotalDesc.text = pedidoCompra.valorComDesconto.toString();
                });               
              },
            ),
          ],
        )),
    );
  }

  Widget _criarCampoTexto(String nome, TextEditingController controller, TextInputType tipo){
  return TextFormField(
          controller: controller,
          keyboardType: tipo,
          decoration: InputDecoration(
            hintText: nome
          ),
          style: TextStyle(color: Colors.grey, fontSize: 17.0),
          enabled: false,
        );
}
Widget _criarDropDownTipoPgto(){
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0,0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 336.0,
            child: DropdownButton<String>(
            value: _dropdownValueTipoPgto,
            style: TextStyle(
            color: Colors.black
            ),
            hint: Text("Selecionar Tipo Pagamento"),
            onChanged: (String newValue) {
              setState(() {
                _dropdownValueTipoPgto = newValue;
                pedidoCompra.tipoPagamento = _dropdownValueTipoPgto;
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

  Widget _criarDropDownFornecedor(){
    empresas = Firestore.instance.collection('empresas').snapshots();
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
              width: 336.0,
                child: DropdownButton(
                  value: _dropdownValueCliente,
                  hint: Text("Selecionar fornecedor"),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValueCliente = newValue;
                      pedidoCompra.labelTelaPedidos = _dropdownValueCliente;
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
}