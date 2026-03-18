import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // FONCTION LORSQUE LE BOUTON EST EXECUTE
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    Key? key, // Permettent d'identifier les widgets dans l'arbre des widgets
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 50,
    this.color,
  }) : super(key: key); // Cela appelle le constructeur de la classe parent StatelessWidget

  @override
  Widget build(BuildContext context) { // METHODE QUI CONSTRUIT UN INTERFACE GRAPHIQUE DE WIDGET

    // Variable qui contient le loader, texte ou icone + texte
    // On utilise un Stack ou une structure simple pour gérer la visibilité
    Widget content = Stack(  // permet de superposer plusieurs widgets les uns sur les autres
      alignment: Alignment.center,
      children: [
        // Si le bouton est en chargement cela affiche un indicateur de chargement
        Visibility(
          visible: isLoading,
          child: const SizedBox(
            height: 20, // La taille lors du loading avec height et wight
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2, // Epaisseur de la bordure du cercle
            ),
          ),
        ),

        // Gestion de l'affichage Texte + Icône
        Visibility(
          visible: !isLoading && icon != null,
          child: Row( // Mettre dans la variable content .Et row les places horizontalement
            mainAxisAlignment: MainAxisAlignment.center, // Regle l'alignement de la ligne
            children: [
              Icon(icon), // ICON prend l'icone fourni qui sera affichde
              const SizedBox(width: 8), // Permet de mettre des espacement entre l'icone et le texte
              Text(text), // Affiche le texte du bouton
            ],
          ),
        ),

        // Sinon on affiche que le texte
        Visibility(
          visible: !isLoading && icon == null,
          child: Text(text),
        ),
      ],
    );


    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [

          Visibility(
            visible: isOutlined,
            child: SizedBox.expand(
              child: OutlinedButton(
                onPressed: isLoading ? null : onPressed, // Si le bouton est clique elle ne peut pas etre recliquer
                child: content,
              ),
            ),
          ),

          // Si y a pas de outlined on cree le bouton avec :
          Visibility(
            visible: !isOutlined,
            child: SizedBox.expand(
              child: ElevatedButton( // Bouton avec couleur
                style: ElevatedButton.styleFrom( // Permet de definir le style du bouton
                  backgroundColor: color,
                ),
                onPressed: isLoading ? null : onPressed,
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}