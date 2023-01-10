import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Utils/cuadro.dart';

class Dibujo extends StatelessWidget {
  Dibujo(this.data);

  final data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child:
        Cuadro(data: data),

      ),
    );
  }
}
