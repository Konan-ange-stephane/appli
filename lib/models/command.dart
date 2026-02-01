/// Modèle représentant une commande à envoyer selon le protocole Arduino
class Command {
  final CommandType type;

  Command({
    required this.type,
  });

  /// Convertit la commande en string pour l'envoi vers l'Arduino
  /// L'Arduino attend un seul caractère: A, R, G, D, ou S
  String toProtocolString() {
    switch (type) {
      case CommandType.forward:
        return 'A'; // Avancer
      case CommandType.backward:
        return 'R'; // Reculer
      case CommandType.left:
        return 'G'; // Gauche
      case CommandType.right:
        return 'D'; // Droite
      case CommandType.stop:
        return 'S'; // Stop
    }
  }
}

enum CommandType {
  forward,   // A - Avancer
  backward,  // R - Reculer
  left,      // G - Gauche
  right,     // D - Droite
  stop,      // S - Stop
}

