/// Constantes de l'application
class AppConstants {
  // Vitesse par défaut
  static const double defaultSpeed = 150.0;
  static const double minSpeed = 0.0;
  static const double maxSpeed = 255.0;

  // Commandes Arduino (protocole série)
  static const String commandForward = 'A';  // Avancer
  static const String commandBackward = 'R'; // Reculer
  static const String commandLeft = 'G';     // Gauche
  static const String commandRight = 'D';    // Droite
  static const String commandStop = 'S';     // Stop
}

