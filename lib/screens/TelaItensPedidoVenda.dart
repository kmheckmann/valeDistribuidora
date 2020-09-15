import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';

class TelaItensPedidovenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaItensPedidovenda({this.pedidoVenda, this.itemPedido, this.snapshot});

  @override
  _TelaItensPedidovendaState createState() => _TelaItensPedidovendaState(this.snapshot, this.pedidoVenda, this.itemPedido);
}

class _TelaItensPedidovendaState extends State<TelaItensPedidovenda> {
  final DocumentSnapshot snapshot;
  ItemPedido itemPedido;
  PedidoVenda pedidoVenda;

  _TelaItensPedidovendaState(this.snapshot, this.pedidoVenda, this.itemPedido);

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}