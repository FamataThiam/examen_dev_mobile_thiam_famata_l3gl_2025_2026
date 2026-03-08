import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {


  final String text;


  final VoidCallback? onPressed;  // FONCTION LORSQUE LE BOUTON EST EXECUTE


  final bool isLoading;


  final bool isOutlined;


  final IconData? icon;


  final double? width;


  final double? height;


  final Color? color;


  const CustomButton({
    Key? key,  // Permettent d'identifier les widgets dans l'arbre des widgets
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 50,
    this.color,
  }) : super(key: key);  // Cela appelle le constructeur de la classe parent StatelessWidget


  @override
  Widget build(BuildContext context) { // METHODE QUI CONSTRUIT UN INTERFACE  GRAPHIQUE DE WIDGET


    Widget content; // Variable qui contient qui contient le loader,texte ou icone +texte


    if (isLoading) {
      content = const SizedBox(
        height: 20, // La taille lors du loading avec height et wight
        width: 20,
        child: CircularProgressIndicator(  // Si le bouton est en chargement cela affiche un indicateur de chargement (le petit rond en chargement)
          strokeWidth: 2,  // Epaisseur de la bordure du cercle
        ),
      );
    }
    // Si une icône est fournie
    else if (icon != null) {
      content = Row(   // Mettre dans la variable content .Et row les places horizontalement
        mainAxisAlignment: MainAxisAlignment.center,  // Regle l'alignement de la ligne et place les element texte et icone au centre
        children: [  // Les elements a afficher dans le widgets
          Icon(icon),  // ICON prend l'icone fourni qui sera affichde
          const SizedBox(width: 8),  // Permet de mettre des espacement entre l'icone et le texte
          Text(text),   // Affiche le texte du bouton
        ],
      );
    }

    else {
      content = Text(text);  // Sinon on affiche que le texte
    }


    if (isOutlined) {
      return SizedBox(  // Donne la taille du bouton
        width: width,
        height: height,
        child: OutlinedButton(  // Widget contenu dans le SizeBox et le outlined bouton avec contour
          onPressed: isLoading ? null : onPressed,  // Si le bouton est clique elle ne peut pas etre recliquer encore sinon elle est cliquable
          child: content,
        ),
      );
    }


    return SizedBox(  // Si y a pas de outlined on cree le bouton avec:
      width: width,
      height: height,
      child: ElevatedButton(  // Bouton avec couleur
        style: ElevatedButton.styleFrom(  // Permet de definir le style du bouton
          backgroundColor: color,
        ),
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );
  }
}