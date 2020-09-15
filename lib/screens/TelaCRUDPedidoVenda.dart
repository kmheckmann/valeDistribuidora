import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tcc_2/controller/EmpresaController.dart';
import 'package:tcc_2/controller/EstoqueProdutoController.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/controller/UsuarioController.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaItensPedidoVenda.dart';

class TelaCRUDPedidoVenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final DocumentSnapshot snapshot;
  final Usuario vendedor;

  TelaCRUDPedidoVenda({this.pedidoVenda, this.snapshot, this.vendedor});

  @override
  _TelaCRUDPedidoVendaState createState() =>
      _TelaCRUDPedidoVendaState(this.pedidoVenda, this.snapshot, this.vendedor);
}

class _TelaCRUDPedidoVendaState extends State<TelaCRUDPedidoVenda> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  Usuario vendedor;

  _TelaCRUDPedidoVendaState(this.pedidoVenda, this.snapshot, this.vendedor);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  Stream<QuerySnapshot> empresas;
  String _dropdownValueTipoPgto;
  String _dropdownValueTipoPedido;
  String _dropdownValueFornecedor;
  final _controllerVlTotal = TextEditingController();
  final _controllerVlTotalDesc = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  final _controllerFormaPgto = TextEditingController();
  final _controllerFornecedor = TextEditingController();
  final _controllerTipoPedido = TextEditingController();
  bool _novocadastro;
  bool _permiteEditar = true;
  bool _vlCheckBox;
  String _nomeTela;
  Empresa empresa = Empresa();
  PedidoController _controllerPedido = PedidoController();
  EmpresaController _controllerEmpresa = EmpresaController();
  UsuarioController _controllerUsuario = UsuarioController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  List<String> tipoPagamento = List<String>();
  List<String> tipoPedido = List<String>();

  @override
  void initState() {
    tipoPagamento.add('À Vista');
    tipoPagamento.add('Cheque');
    tipoPagamento.add('Boleto');
    tipoPagamento.add('Duplicata');

    tipoPedido.add("Normal");
    tipoPedido.add("Troca");
    tipoPedido.add("Bonificação");

    super.initState();
    if (pedidoVenda != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
      _controllerIdPedido.text = pedidoVenda.id;
      _controllerPercentDesc.text = pedidoVenda.percentualDesconto.toString();
      _controllerVendedor.text = pedidoVenda.user.nome;
      _dropdownValueTipoPgto = pedidoVenda.tipoPagamento;
      _dropdownValueFornecedor = pedidoVenda.empresa.nomeFantasia;
      _controllerVlTotalDesc.text = pedidoVenda.valorComDesconto.toString();
      _novocadastro = false;
      _vlCheckBox = pedidoVenda.pedidoFinalizado;
      _controllerData.text = _formatarData(pedidoVenda.dataPedido);
      if (pedidoVenda.dataFinalPedido != null)
        _controllerDataFinal.text = _formatarData(pedidoVenda.dataFinalPedido);
      if (pedidoVenda.pedidoFinalizado == true) _permiteEditar = false;
    } else {
      _nomeTela = "Novo Pedido";
      pedidoVenda = PedidoVenda();
      pedidoVenda.dataPedido = DateTime.now();
      pedidoVenda.ehPedidoVenda = true;
      pedidoVenda.valorTotal = 0.0;
      pedidoVenda.percentualDesconto = 0.0;
      //formatar data
      _controllerData.text = _formatarData(pedidoVenda.dataPedido);
      _novocadastro = true;
      _vlCheckBox = false;
      pedidoVenda.pedidoFinalizado = false;
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
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.loop),
              onPressed: () async {
                await _controllerPedido.atualizarCapaPedido(pedidoVenda.id);
                _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
                _controllerVlTotalDesc.text =
                    pedidoVenda.valorComDesconto.toString();
                _controllerPercentDesc.text =
                    pedidoVenda.percentualDesconto.toString();
                _controllerFornecedor.text = _dropdownValueFornecedor;
                _controllerFormaPgto.text = pedidoVenda.tipoPagamento;
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.apps),
          backgroundColor: Colors.blue,
          onPressed: () async {
            await _controllerEmpresa
                .obterEmpresaPorDescricao(_dropdownValueFornecedor);
            empresa = _controllerEmpresa.empresa;
            await _controllerUsuario.obterUsuarioPorCPF(vendedor.cpf);
            vendedor = _controllerUsuario.usuario;
            pedidoVenda.pedidoFinalizado = _vlCheckBox;

            if (pedidoVenda.pedidoFinalizado == true &&
                pedidoVenda.dataFinalPedido == null) {
              await _controllerPedido.verificarSePedidoTemItens(pedidoVenda);

              if (_controllerPedido.podeFinalizar == true) {
                //AQUI DEVO COLOCAR METODO PRA TIRAR ESTOQUE
                pedidoVenda.dataFinalPedido = DateTime.now();
                _controllerDataFinal.text =
                    _formatarData(pedidoVenda.dataFinalPedido);
                _codigoBotaoSalvar();
              } else {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text(
                      "O pedido não pode ser finalizado pois não contém itens!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ));
              }
            } else {
              _codigoBotaoSalvar();
            }
          }),
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _criarCampoTexto(
                  "Código Pedido", _controllerIdPedido, TextInputType.number),
              _criarCampoTexto(
                  "Vendedor", _controllerVendedor, TextInputType.text),
              _criarCampoTexto(
                  "Data Pedido", _controllerData, TextInputType.text),
              _criarCampoTexto(
                  "Data Finalização", _controllerDataFinal, TextInputType.text),
              _campoFornecedor(),
              _campoTipoPgto(),
              _campoTipoPedido(),
              _criarCampoTexto(
                  "Valor Total", _controllerVlTotal, TextInputType.number),
              _criarCampoTexto("Valor Total Com Desconto",
                  _controllerVlTotalDesc, TextInputType.number),
              TextFormField(
                enabled: _permiteEditar,
                controller: _controllerPercentDesc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "% Desconto"),
                style: _style(),
                onChanged: (texto) {
                  pedidoVenda.percentualDesconto = double.parse(texto);
                  setState(() {
                    _controllerPedido.calcularDesconto(pedidoVenda);
                    pedidoVenda.valorComDesconto =
                        _controllerPedido.pedidoCompra.valorComDesconto;
                    _controllerVlTotalDesc.text =
                        pedidoVenda.valorComDesconto.toString();
                  });
                },
              ),
              _criarCampoCheckBox(),
            ],
          )),
    );
  }

  Widget _criarCampoTexto(
      String nome, TextEditingController controller, TextInputType tipo) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(hintText: nome, 
                                  labelText: nome,
                                  labelStyle:TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
      style: TextStyle(color: Colors.grey, fontSize: 17.0),
      enabled: false,
    );
  }

  Widget _criarDropDown(List<String> lista, String item, String textoHint) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 336.0,
            child: DropdownButton<String>(
              value: _dropdownValueTipoPgto,
              style: TextStyle(color: Colors.black),
              hint: Text(textoHint),
              onChanged: (String newValue) {
                setState(() {
                  if (item == "TipoPgto") {
                    _dropdownValueTipoPgto = newValue;
                    pedidoVenda.tipoPagamento = _dropdownValueTipoPgto;
                  } else {
                    _dropdownValueTipoPedido = newValue;
                    pedidoVenda.tipoPedido = _dropdownValueTipoPedido;
                  }
                });
              },
              items: lista.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _criarDropDownFornecedor() {
    empresas = Firestore.instance.collection('empresas').snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: empresas,
        builder: (context, snapshot) {
          var length = snapshot.data.documents.length;
          DocumentSnapshot ds = snapshot.data.documents[length - 1];
          return Container(
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 336.0,
                  child: DropdownButton(
                    value: _dropdownValueFornecedor,
                    style: TextStyle(color: Colors.black),
                    hint: Text("Selecionar fornecedor"),
                    onChanged: (String newValue) {
                      setState(() {
                        _dropdownValueFornecedor = newValue;
                        pedidoVenda.labelTelaPedidos = _dropdownValueFornecedor;
                      });
                    },
                    items: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                          value: document.data['nomeFantasia'],
                          child: Container(
                            child: Text(document.data['nomeFantasia'],
                                style: TextStyle(color: Colors.black)),
                          ));
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _vlCheckBox == true,
            onChanged: pedidoVenda.pedidoFinalizado
                ? null
                : (bool novoValor) {
                    setState(() {
                      if (novoValor) {
                        _vlCheckBox = true;
                      } else {
                        _vlCheckBox = false;
                      }
                    });
                  },
          ),
          Text(
            "Finalizado?",
            style: _style(),
          ),
        ],
      ),
    );
  }

  void _codigoBotaoSalvar() async {
    // método criado para não precisar repetir duas vezes o mesmo codigo na hora que clica no salvar
    if (_dropdownValueTipoPgto != null && _dropdownValueFornecedor != null) {
      Map<String, dynamic> mapa =
          _controllerPedido.converterParaMapa(pedidoVenda);
      print(vendedor.id);
      Map<String, dynamic> mapaVendedor = Map();
      mapaVendedor["id"] = vendedor.id;
      Map<String, dynamic> mapaEmpresa = Map();
      mapaEmpresa["id"] = empresa.id;
      pedidoVenda.pedidoFinalizado = _vlCheckBox;

      if (_novocadastro) {
        _novocadastro = false;
        await _controllerPedido.obterProxID();
        pedidoVenda.id = _controllerPedido.proxID;
        _controllerPedido.salvarPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoVenda.id);
      } else {
        _controllerPedido.editarPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoVenda.id);
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (contexto) => TelaItensPedidovenda(
                pedidoVenda: pedidoVenda,
                snapshot: snapshot,
              )));
    } else {
      _scaffold.currentState.showSnackBar(SnackBar(
        content: Text("Todos os campos da tela devem ser informados!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  TextStyle _style() {
    if (pedidoVenda.pedidoFinalizado) {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    }
  }

  String _formatarData(DateTime data) {
    return (data.day.toString() +
        "/" +
        data.month.toString() +
        "/" +
        data.year.toString() +
        " " +
        (new DateFormat.Hms().format(data)));
  }

  Widget _campoTipoPgto() {
    _controllerFormaPgto.text = pedidoVenda.tipoPagamento;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Tipo Pagamento", _controllerFormaPgto, TextInputType.text);
    } else {
      return _criarDropDown(tipoPagamento, "TipoPgto", "Selecionar Forma Pagamento");
    }
  }

    Widget _campoTipoPedido() {
    _controllerTipoPedido.text = pedidoVenda.tipoPedido;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Tipo Pedido", _controllerTipoPedido, TextInputType.text);
    } else {
      return _criarDropDown(tipoPedido, "TipoPedido", "Selecionar Tipo Pedido");
    }
  }

  Widget _campoFornecedor() {
    _controllerFornecedor.text = pedidoVenda.empresa.nomeFantasia;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Fornecedor", _controllerFornecedor, TextInputType.text);
    } else {
      return _criarDropDownFornecedor();
    }
  }
}
