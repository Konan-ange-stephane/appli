/// Modèle représentant une commande à envoyer
class Command {
  final CommandType type;
  final int? value;

  Command({
    required this.type,
    this.value,
  });

  /// Convertit la commande en string pour l'envoi
  String toProtocolString() {
    switch (type) {
      case CommandType.forward:
        return 'F:$value';
      case CommandType.backward:
        return 'B:$value';
      case CommandType.left:
        return 'L:$value';
      case CommandType.right:
        return 'R:$value';
      case CommandType.stop:
        return 'S';
    }
  }
}

enum CommandType {
  forward,
  backward,
  left,
  right,
  stop,
}

