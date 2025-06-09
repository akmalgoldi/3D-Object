// Variabel Transformasi Objek
float pitch = radians(-15), yaw = 0, roll = 0; 
float crabX = 0, pedY = 0, scaleFactor = 1.0; 

// Variabel Kontrol Kecepatan
float rotRate = 1.5; 
float transRate = 2.0; 
float zoomRate = 0.04; 
float lightRate = 4.0; 

// Variabel Tekstur & Model
PShape akmModel;
PImage textureA, textureB; 
boolean useTextureB = false;

// Variabel Cahaya
float lightX, lightY, lightZ = 200; 

void setup() {
  size(1280, 720, P3D); 
  // Inisialisasi posisi cahaya Y
  lightY = -height / 4;
  try {
    akmModel = loadShape("AKM.obj");
    if (akmModel != null) akmModel.scale(50); 
    textureA = loadImage("texture.jpg");
    textureB = loadImage("texture2.jpg");
  } catch (Exception e) {
    println("Error loading assets: " + e.getMessage());
  }

  println("Kontrol: Panah (Pitch/Yaw), A/D (Roll), Q/E (Crab), W/S (Ped), +/- (Zoom)");
  println("Kontrol Cahaya: J/L (X), I/K (Y), U/O (Z)");
  println("Lain-lain: T (Toggle Tekstur), R (Reset)");
}

void draw() {
  background(20, 25, 35);

  // Update transformasi berdasarkan input
  updateTransformations();

  // Pencahayaan
  ambientLight(100, 100, 110);
  pointLight(255, 250, 240, lightX, lightY, lightZ);

  // Terapkan Transformasi Objek
  pushMatrix();
  translate(width / 2 + crabX, height / 2 + pedY, 0); 
  rotateZ(roll);
  rotateX(pitch);
  rotateY(yaw);
  scale(scaleFactor);

  // Gambar Model dengan Tekstur
  drawModel();
  popMatrix();
}

// Mengupdate posisi/rotasi berdasarkan tombol yang ditekan
void updateTransformations() {
  // Rotasi (Pitch, Yaw, Roll)
  if (keyPressed) {
    if (keyCode == UP) pitch -= radians(rotRate);
    if (keyCode == DOWN) pitch += radians(rotRate);
    if (keyCode == LEFT) yaw -= radians(rotRate);
    if (keyCode == RIGHT) yaw += radians(rotRate);

    // Translasi (Crab, Pedestal) & Zoom & Cahaya
    switch (key) {
      case 'a':
      case 'A':
        roll -= radians(rotRate);
        break;
      case 'd':
      case 'D':
        roll += radians(rotRate);
        break;
      case 'q':
      case 'Q':
        crabX -= transRate;
        break;
      case 'e':
      case 'E':
        crabX += transRate;
        break;
      case 'w':
      case 'W':
        pedY -= transRate;
        break;
      case 's':
      case 'S':
        pedY += transRate;
        break;
      case '+':
      case '=':
        scaleFactor += zoomRate;
        break;
      case '-':
      case '_':
        scaleFactor = max(0.01, scaleFactor - zoomRate);
        break; // Zoom min
      case 'j':
      case 'J':
        lightX -= lightRate;
        break;
      case 'l':
      case 'L':
        lightX += lightRate;
        break;
      case 'i':
      case 'I':
        lightY -= lightRate;
        break;
      case 'k':
      case 'K':
        lightY += lightRate;
        break;
      case 'u':
      case 'U':
        lightZ -= lightRate;
        break;
      case 'o':
      case 'O':
        lightZ += lightRate;
        break;
    }
  }
}

// Fungsi untuk menggambar model dan mengatur tekstur
void drawModel() {
  if (akmModel == null) {
    fill(255, 0, 0, 180); 
    box(100); 
    return;
  }

  akmModel.disableStyle();

  PImage currentTexture = useTextureB ? textureB : textureA;
  if (currentTexture != null) {
    akmModel.setTexture(currentTexture);
    akmModel.enableStyle(); 
  } else {
    fill(255, 0, 0, 180); 
    println("WARNING: Tekstur tidak ditemukan.");
  }
  shape(akmModel);
}

// Toggle Tekstur & Reset (saat tombol dilepas)
void keyReleased() {
  if (key == 't' || key == 'T') {
    useTextureB = !useTextureB;
  } else if (key == 'r' || key == 'R') {
    // Reset semua variabel
    pitch = radians(-15);
    yaw = 0;
    roll = 0;
    crabX = 0;
    pedY = 0;
    scaleFactor = 1.0;
    lightX = 0;
    lightY = -height / 4;
    lightZ = 200;
    useTextureB = false;
  }
}
