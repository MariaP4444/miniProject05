import oscP5.*;
import netP5.*;

OscP5 osc;
NetAddress pureDataAddress;

//variables for data
String[] lines;
String[][] data;


//to show info song
int currentSongIndex = 1; 
int songDuration = 4000; 
int songStartTime;

int energy = 0;
int bpm = 0;
int danceability = 0; 
String mode = null;
int valence = 0; 

// Energy
ParticleSystem ps;
int minEnergy = 9;
int maxEnergy = 97;

// Danceability
int minDanceability = 23; 
int maxDanceability = 96; 

// BPM and Mode
int rad = 60;        
float xpos, ypos;    
float xspeed = 2.8;  
float yspeed = 2.2;  
int xdirection = 1;  // Dirección en el eje x: 1 es hacia la derecha, -1 es hacia la izquierda
int ydirection = 1;  // Dirección en el eje y: 1 es hacia abajo, -1 es hacia arriba

// Valence
int minValence = 0;      // Valor mínimo de valence
int maxValence = 97;     // Valor máximo de valence
float armAngle = 0; // Ángulo de los brazos
float armSpeed = 0; // Velocidad de movimiento de los brazos


// Variable para controlar si la cara está a la izquierda o a la derecha
boolean isFaceOnRight = true;  // La cara comienza a la derech

boolean changeMovement = false;  // Para saber si el movimiento debe cambiar
boolean isLegsMoving = false;  // Para saber si las piernas deben moverse

// Variables globales para los cuadros de la cara
float leftBoxX, leftBoxY, rightBoxX, rightBoxY;
float boxWidth = 100;  // Ancho de los cuadros
float boxHeight = 100; // Alto de los cuadros
color cuadroColor = color(250);  

void setup() {
  size(800, 800);
  processData();
  loadVar();
}


void loadVar(){
  PImage img = loadImage("imagen.png"); 
  ps = new ParticleSystem(0, new PVector(width / 2, height - 60), img);
  songStartTime = millis(); 
  xpos = width / 2;   
  ypos = height / 2;  
  leftBoxX = 50;  // Cuadro izquierdo
  leftBoxY = height / 2 - boxHeight / 2;
  rightBoxX = width - 150;  // Cuadro derecho
  rightBoxY = height / 2 - boxHeight / 2;
}


void processData(){
  lines = loadStrings("datos.csv");
  if (lines == null) {
    println("No se pudo cargar el archivo CSV.");
    exit();
  }
  osc = new OscP5(this, 15);
  pureDataAddress = new NetAddress("127.0.0.1", 15);
  

 
  data = new String[lines.length][];
  for (int i = 1; i < lines.length; i++) {
    String[] aux = splitTokens(lines[i], ";");
    if (aux.length == 7) {
      data[i] = splitTokens(lines[i], ";");
    }
  }
  
}


void sendPureData(float value, String route) {
  OscMessage msg = new OscMessage(route); // Define la ruta de Pure Data
  msg.add(value); // Añade el valor como argumento del mensaje
  osc.send(msg, pureDataAddress);
}

void draw() {
  background(0);  
  
  
  if (millis() - songStartTime >= songDuration) {
    currentSongIndex++;
    songStartTime = millis(); 
    if (currentSongIndex >= data.length) {
      currentSongIndex = 1; 
    }
  }
  int currentSecond = (millis() - songStartTime) / 1000;

  fill(100, 100, 255, 0);  // Color semi-transparente para los cuadros
  rect(leftBoxX, leftBoxY, boxWidth, boxHeight);
  rect(rightBoxX, rightBoxY, boxWidth, boxHeight);
  energy = parseInt(data[currentSongIndex][6]);
  bpm = parseInt(data[currentSongIndex][2]);
  danceability = parseInt(data[currentSongIndex][4]); 
  mode = data[currentSongIndex][3];
  valence = parseInt(data[currentSongIndex][5]); 

  
  

  //Smoke Particle System
  float windStrength = map(energy, minEnergy, maxEnergy, -0.2, 0.2);
  PVector wind = new PVector(windStrength, 0);
  ps.applyForce(wind);
  ps.run();
  for (int i = 0; i < 2; i++) {
    ps.addParticle();
  }
  drawVector(wind, new PVector(width / 2, 200, 0), 500);
  
  

  //Bounce
  xspeed = map(bpm, 60, 200, 1.0, 6.0);
  yspeed = xspeed * 0.8;
  if (mode.equals("Major")) {
    fill(255, 105, 180);  
  } else if (mode.equals("Minor")) {
    fill(0, 255, 0);  
  }
  xpos = xpos + (xspeed * xdirection);
  ypos = ypos + (yspeed * ydirection);
  if (xpos > width - rad || xpos < rad) {
    xdirection *= -1;
  }
  if (ypos > height - rad || ypos < rad) {
    ydirection *= -1;
  }
  ellipse(xpos, ypos, rad, rad);
  
  
  // Dancing person 
  drawDancingPerson(danceability);
  armSpeed = map(danceability, minDanceability, maxDanceability, 0.02, 0.2);
  armAngle += armSpeed; 
  if (armAngle > TWO_PI) {
    armAngle -= TWO_PI;
  }
  
  // Happy face
  drawHappyFace(valence);
  
  if(isLegsMoving == true){
    danceability *= -1;
  }
  
  
    
    sendPureData(bpm,"/bpm");
    if(mode.equals("Major")){
      sendPureData(1,"/mode");
    }
    else{
      sendPureData(0,"/mode");}
      
    sendPureData(danceability,"/danceability");
    sendPureData(valence, "/valence");
    sendPureData(energy, "/energy");
 
  
  /// 
    fill(cuadroColor);
   rect(width - 100, 50,50,50);
    
  //Song information
  String trackName = data[currentSongIndex][0];
  int num = parseInt(data[currentSongIndex][1]);
  fill(255);
  textSize(16);
  textAlign(CENTER);
  text("Canción: " + trackName, width / 2, 30);
  text("Posición en Spotify: " + nf(num,1,0), width / 2, 50);
  text("Energy: " + nf(energy, 1, 0), width / 2, 70);
  text("BPM: " + nf(bpm, 1, 0), width / 2, 90);
  text("Mode: " + mode, width / 2, 110);
  text("Danceability: " + nf(danceability, 1, 0), width / 2, 130);
  text("Valence: " + nf(valence, 1, 0), width / 2, 150);
}


// Function to draw a vector as an arrow
void drawVector(PVector v, PVector loc, float scale) {
  pushMatrix();
  float arrowSize = 4;
  translate(loc.x, loc.y);
  stroke(255);
  rotate(v.heading());
  float len = v.mag() * scale;
  line(0, 0, len, 0);
  line(len, 0, len - arrowSize, +arrowSize / 2);
  line(len, 0, len - arrowSize, -arrowSize / 2);
  popMatrix();
}

// Función para dibujar la cara
void drawHappyFace(int valence) {
  float faceX = isFaceOnRight ? width - 100 : 100;  // Si está a la derecha, la cara está en el borde derecho; de lo contrario, a la izquierda
  float faceY = height / 2; 
  float faceSize = 100;     
  float eyeSize = 10;        // Tamaño de los ojos

  float smileAmplitude = map(valence, 0, 97, 5, 25);  

  int faceRed, faceGreen, faceBlue;

  if (valence <= 32) {
    faceRed = (int) map(valence, 0, 32, 255, 255);  
    faceGreen = (int) map(valence, 0, 32, 0, 100);  
    faceBlue = 0;  
  } else if (valence <= 64) {
    faceRed = (int) map(valence, 33, 64, 255, 255);  
    faceGreen = (int) map(valence, 33, 64, 100, 170); 
    faceBlue = 0;  
  } else {
    faceRed = (int) map(valence, 65, 97, 255, 255);  
    faceGreen = (int) map(valence, 65, 97, 170, 255); 
    faceBlue = 0;
  }

  fill(faceRed, faceGreen, faceBlue);   
  noStroke();
  ellipse(faceX, faceY, faceSize, faceSize);  // Dibuja la cara
  
  // Ojos
  fill(0);  
  ellipse(faceX - faceSize / 4, faceY - faceSize / 5, eyeSize, eyeSize);  
  ellipse(faceX + faceSize / 4, faceY - faceSize / 5, eyeSize, eyeSize);  

  // Sonrisa
  noFill();
  stroke(0);
  strokeWeight(2);
  arc(faceX, faceY + faceSize / 8, faceSize / 2, smileAmplitude, 0, PI);  
}

// Función que detecta el clic y cambia la posición de la cara

void mousePressed() {
  // Verificar si el clic está dentro del rectángulo especificado
  if (mouseX >= width - 100 && mouseX <= width - 50 && mouseY >= 50 && mouseY <= 100) {
    sendPureData(1, "/clickArea");  // Envía 1 si está en el área
    cuadroColor = color(random(255), random(255), random(255));
    sendPureData(0, "/button");
  } else {
    sendPureData(0, "/clickArea");  // Envía 0 si está fuera del área
    sendPureData(1, "/button");
  }
  
  // Cambia la posición de la cara al hacer clic en los cuadros de la izquierda o derecha
  if (mouseX >= leftBoxX && mouseX <= leftBoxX + boxWidth && mouseY >= leftBoxY && mouseY <= leftBoxY + boxHeight) {
    isFaceOnRight = false;  // Coloca la cara a la izquierda
  } else if (mouseX >= rightBoxX && mouseX <= rightBoxX + boxWidth && mouseY >= rightBoxY && mouseY <= rightBoxY + boxHeight) {
    isFaceOnRight = true;  // Coloca la cara a la derecha
  }
  
  // Coordenadas del cuerpo de la persona
  float bodyX = width / 2;
  float bodyY = height / 2;
  float bodyWidth = 80;  // Ancho del cuerpo
  float bodyHeight = 120;  // Alto del cuerpo

  // Detectar si el clic ocurrió dentro del área del cuerpo
  float d = dist(mouseX, mouseY, bodyX, bodyY);
  if (d < bodyWidth / 2) { // Si el clic fue dentro del cuerpo
    changeMovement = !changeMovement;  // Cambiar el estado del movimiento
    isLegsMoving = !isLegsMoving;  // Invertir si las piernas deben moverse
    danceability *= -1;  // Multiplicar el valor de danceability por -1
  }
}
// Modificar la función `drawDancingPerson` para cambiar el movimiento
void drawDancingPerson(int danceability) {
  float scale = map(danceability, minDanceability, maxDanceability, 0.5, 2.0); 
  
  // body
  fill(255);
  ellipse(width / 2, height / 2, 80 * scale, 120 * scale); // Cuerpo

  // head
  fill(255, 224, 189);  // Color de piel
  ellipse(width / 2, height / 2 - 80 * scale, 40 * scale, 40 * scale); // Cabeza

  if (changeMovement) {
    // Si es true, mover las piernas en vez de los brazos
    // Mover piernas
    float leftLegY = height / 2 + 40 * scale + sin(armAngle) * 20 * scale;
    float rightLegY = height / 2 + 40 * scale + sin(armAngle) * 20 * scale;
    
    line(width / 2 - 30 * scale, leftLegY, width / 2 - 70 * scale, leftLegY + 60 * scale); // Pierna izquierda
    line(width / 2 + 30 * scale, rightLegY, width / 2 + 70 * scale, rightLegY + 60 * scale); // Pierna derecha
  } else {
    // Si es false, mover los brazos
    //arms
    stroke(255);
    float leftArmY = height / 2 - 40 * scale + sin(armAngle) * 20 * scale;  // Movimiento del brazo izquierdo
    float rightArmY = height / 2 - 40 * scale + sin(armAngle) * 20 * scale; // Movimiento del brazo derecho
    line(width / 2 - 40 * scale, height / 2 - 40 * scale, width / 2 - 80 * scale, leftArmY); // Brazo izquierdo
    line(width / 2 + 40 * scale, height / 2 - 40 * scale, width / 2 + 80 * scale, rightArmY); // Brazo derecho
  }

  // El resto de las piernas siempre se mueven si no está cambiado el movimiento de los brazos
  if (!changeMovement) {
    line(width / 2 - 30 * scale, height / 2 + 40 * scale, width / 2 - 70 * scale, height / 2 + 100 * scale); // Pierna izquierda
    line(width / 2 + 30 * scale, height / 2 + 40 * scale, width / 2 + 70 * scale, height / 2 + 100 * scale); // Pierna derecha
  }
}
