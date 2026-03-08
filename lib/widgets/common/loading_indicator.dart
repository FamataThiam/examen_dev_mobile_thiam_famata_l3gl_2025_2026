import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {

  final double size;
  final Color color;


  const LoadingIndicator({
    Key? key,
    this.size = 30.0,       // valeur par défaut = 30
    this.color = Colors.blue, // couleur par défaut
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator( // Widget qui affiche un cercle qui tourne
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color), // Animation et prend une couleur
        ),
      ),
    );
  }
}