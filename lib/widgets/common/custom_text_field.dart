import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Widget personnalisé pour un champ de texte
class CustomTextField extends StatefulWidget {

  final String label;

  // Recupere le valeur du champs
  final TextEditingController? controller; // Un controller qui sert à récuperer le texte d'un champs de saisie(comme un textfield)

  final String? hint;

  // Fonction de validation
  final String? Function(String?)? validator;

  final bool obscureText;

  final TextInputType? keyboardType;

  final IconData? prefixIcon;

  final int maxLines;

  const CustomTextField({   // le constructeur variable mis en place pour mon widgets
    Key? key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
  }) : super(key: key);


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();  // méthode qui crée l’état du widget.
  // méthode obliqatoire pour un statefulwidget elle montre qu'on a un etat et qu'il peut changer et cela est géré par _CustomTextFieldState()
}

class _CustomTextFieldState extends State<CustomTextField> {  // La classe est en privee

  // Variable pour gérer l'affichage ou non du mot de passe
  bool _isHidden = true;

  // méthode qui construit l’interface de ce widget.
  @override
  Widget build(BuildContext context) { // Context donne l'information a l'arbre

    return TextFormField(  // Permet la saisie du code


      controller: widget.controller, // Relie le champs au controller envoye

      validator: widget.validator,

      keyboardType: widget.keyboardType,

      maxLines: widget.obscureText ? 1 : widget.maxLines,  // Si le obscureText est a true alors on prend une seul ligne car le mot de passe utilise un seul ligne

      obscureText: widget.obscureText ? _isHidden : false, // Si le texte est tapé et obsuretexte est a true on affiche le test mais caché on conclut que c(est un potentiel mot de passe

      decoration: InputDecoration(

        labelText: widget.label,

        hintText: widget.hint,


        // SI l'icone est fournie alors on met le texte apres
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        // On le met seulement si c'est un mot de passe gére l'oeil
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _isHidden
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {

            setState(() {
              _isHidden = !_isHidden;
            });

          },
        )
            : null,

        // Style du champ
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}