import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSilence = false; // État du switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white), // bouton trois traits à gauche
          onPressed: () {
            print("Menu cliqué !");
          },
        ),
        title: Text(
          "Télécommande",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.error_outline, color: Colors.white), // bouton exclamation
            onPressed: () {
              print("Bouton ! cliqué");
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grand cercle avec flèches
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade200,
                  ),
                ),
                // Flèche haut
                Positioned(
                  top: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.arrow_drop_up, color: Colors.white),
                    onPressed: () => print("Avancer"),
                  ),
                ),
                // Flèche bas
                Positioned(
                  bottom: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    onPressed: () => print("Reculer"),
                  ),
                ),
                // Flèche gauche
                Positioned(
                  left: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: () => print("Gauche"),
                  ),
                ),
                // Flèche droite
                Positioned(
                  right: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.arrow_right, color: Colors.white),
                    onPressed: () => print("Droite"),
                  ),
                ),
                // bouton central ON/OFF
                Positioned(
                  child: GestureDetector(
                    onTap: () => print("ON/OFF cliqué"),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.power_settings_new,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Switch latéral style iPhone sous le bouton d'exclamation
          Positioned(
            top: 80, // ajuste selon ton design
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSilence = !isSilence;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isSilence ? Colors.green : Colors.red,
                    ),
                    child: AnimatedAlign(
                      duration: Duration(milliseconds: 200),
                      alignment: isSilence ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  isSilence ?  'Mode joystick' : 'Mode bouton',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ),

          // Bouton + positionné en bas à droite juste au-dessus de la barre de navigation
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                print("Bouton + cliqué !");
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.blue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  print("Home cliqué !");
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  print("Settings cliqué !");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
