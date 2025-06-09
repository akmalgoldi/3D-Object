float pitch = 0, yaw = 0, roll = 0;
float rotationRate = 1.0; 

boolean pitchUpActive, pitchDownActive, yawLeftActive, yawRightActive, rollLeftActive, rollRightActive;
boolean crabLeftActive, crabRightActive, pedestalUpActive, pedestalDownActive;
boolean zoomInActive, zoomOutActive;
boolean lightMoveForwardActive, lightMoveBackwardActive, lightMoveLeftActive, lightMoveRightActive, lightMoveUpActive, lightMoveDownActive;

float crabX = 0, pedY = 0;
float translationRate = 2.0; 
float scaleFactor = 1.0;
float zoomRate = 0.01; 

PShape akmModel;
boolean isTexture2Active = false; 
PImage textureSolidColor; 
PImage textureActual;       

float lightX_scene, lightY_scene, lightZ_scene;
float lightMoveRate = 3.0; 

PFont statusFont;
final int STATUS_FONT_SIZE = 16;

float currentHudYPos;
float hudXPos = 10;
final float HUD_Y_SPACING = 18;

void setup() {
  size(1280, 720, P3D); 

  
  try {
    statusFont = createFont("Arial", STATUS_FONT_SIZE);
    if (statusFont == null) statusFont = createFont("SansSerif", STATUS_FONT_SIZE);
  } catch (Exception e) {
    println("Error font: " + e.getMessage());
  }

  try {
    akmModel = loadShape("AKM.obj");
    if (akmModel == null) println("ERROR: Gagal memuat AKM.obj dari folder 'data'.");
    else {
      println("Model AKM.obj berhasil dimuat.");
      akmModel.scale(50); // Skala model agar sesuai dengan ukuran jendela
    }
  } catch (Exception e) {
    println("EXCEPTION saat memuat AKM.obj: " + e.getMessage());
    akmModel = null;
  }

  try {
    textureSolidColor = loadImage("texture.jpg");
    if (textureSolidColor == null) println("Peringatan: 'texture.jpg' tidak ditemukan. Mode 'warna solid' tidak akan tampil.");
    else println("Tekstur 'texture.jpg' (Warna Solid) berhasil dimuat.");
  } catch (Exception e) {
    println("Error memuat texture.jpg: " + e.getMessage());
    textureSolidColor = null;
  }

  try {
    textureActual = loadImage("texture2.jpg");
    if (textureActual == null) println("Peringatan: 'texture2.jpg' tidak ditemukan. Mode 'ON' tidak akan tampil.");
    else println("Tekstur 'texture2.jpg' (Tekstur 'ON') berhasil dimuat.");
  } catch (Exception e) {
    println("Error memuat texture2.jpg: " + e.getMessage());
    textureActual = null;
  }

  pitch = radians(-15); 
  lightX_scene = 0;
  lightY_scene = -height / 4;
  lightZ_scene = 200;

  displayControlHints();
}

void displayControlHints() {
  println("KONTROL OBJEK (TAHAN TOMBOL)");
  println("Pitch: Panah ATAS/BAWAH | Yaw: Panah KIRI/KANAN | Roll: 'A'/'D'");
  println("Crab: 'Q'/'E' | Pedestal: 'W'/'S' | Zoom: '+/-'");
  println("Tekstur (Toggle ON/OFF): 'T' | Reset All: 'R'");
  println("KONTROL CAHAYA (TAHAN TOMBOL)");
  println("Geser Cahaya X: 'J'/'L' | Y: 'I'/'K' | Z: 'U'/'O'");
}


void draw() {
  background(20, 25, 35); 

  handleContinuousInput(); 

  // --- Pengaturan Pencahayaan ---
  ambientLight(100, 100, 110); 
  pointLight(255, 250, 240, lightX_scene, lightY_scene, lightZ_scene); 

  // --- Transformasi Kamera/View ---
  translate(width / 2, height / 2, 0);
  translate(crabX, pedY, 0); 

  pushMatrix(); 

  // --- Rotasi dan Skala Objek ---
  rotateZ(roll);
  rotateX(pitch);
  rotateY(yaw);
  scale(scaleFactor);

  drawAKMModel(); 
  popMatrix(); 

  displayHUD(); 
}

// --- Fungsi untuk menangani input tombol yang ditekan terus menerus ---
void handleContinuousInput() {
  float radRotationRate = radians(rotationRate);

  if (pitchUpActive) pitch -= radRotationRate;
  if (pitchDownActive) pitch += radRotationRate;
  if (yawLeftActive) yaw -= radRotationRate;
  if (yawRightActive) yaw += radRotationRate;
  if (rollLeftActive) roll -= radRotationRate;
  if (rollRightActive) roll += radRotationRate;

  if (crabLeftActive) crabX -= translationRate;
  if (crabRightActive) crabX += translationRate;
  if (pedestalUpActive) pedY -= translationRate;
  if (pedestalDownActive) pedY += translationRate;  

  if (zoomInActive) scaleFactor += zoomRate;
  if (zoomOutActive) {
    scaleFactor -= zoomRate;
    if (scaleFactor < 0.01f) scaleFactor = 0.01f;
  }

  if (lightMoveLeftActive) lightX_scene -= lightMoveRate;
  if (lightMoveRightActive) lightX_scene += lightMoveRate;
  if (lightMoveUpActive) lightY_scene -= lightMoveRate;
  if (lightMoveDownActive) lightY_scene += lightMoveRate;
  if (lightMoveBackwardActive) lightZ_scene -= lightMoveRate;
  if (lightMoveForwardActive) lightZ_scene += lightMoveRate;
}

// --- Fungsi untuk menggambar Model AKM dan mengatur Tekstur ---
void drawAKMModel() {
  if (akmModel == null) {
    if (frameCount % 120 == 0) println("MODEL ERROR: akmModel null. Tidak bisa digambar.");
    return;
  }

  akmModel.disableStyle(); 

  PImage currentTextureToDisplay = null;

  // Tentukan tekstur mana yang akan ditampilkan
  if (isTexture2Active) { 
    currentTextureToDisplay = textureActual;
  } else { 
    currentTextureToDisplay = textureSolidColor;
  }

  if (currentTextureToDisplay != null) {
    akmModel.setTexture(currentTextureToDisplay);
    akmModel.enableStyle(); 
  } else {
    fill(255, 0, 0, 180); 
    noStroke();
    println("WARNING: Tekstur gagal dimuat untuk status ini.");
  }

  shape(akmModel); 
}

// --- Fungsi untuk menangani penekanan tombol ---
void keyPressed() {
  if (keyCode == UP) pitchUpActive = true;
  else if (keyCode == DOWN) pitchDownActive = true;
  else if (keyCode == LEFT) yawLeftActive = true;
  else if (keyCode == RIGHT) yawRightActive = true;

  switch(key) {
    case 'a': case 'A': rollLeftActive = true; break;
    case 'd': case 'D': rollRightActive = true; break;
    case 'q': case 'Q': crabLeftActive = true; break;
    case 'e': case 'E': crabRightActive = true; break;
    case 'w': case 'W': pedestalUpActive = true; break;
    case 's': case 'S': pedestalDownActive = true; break;
    case '+': case '=': zoomInActive = true; break;
    case '-': case '_': zoomOutActive = true; break;
    case 'j': case 'J': lightMoveLeftActive = true; break;
    case 'l': case 'L': lightMoveRightActive = true; break;
    case 'i': case 'I': lightMoveUpActive = true; break;
    case 'k': case 'K': lightMoveDownActive = true; break;
    case 'u': case 'U': lightMoveBackwardActive = true; break;
    case 'o': case 'O': lightMoveForwardActive = true; break;
    case 't': case 'T':
      isTexture2Active = !isTexture2Active; 
      println("Tekstur: " + (isTexture2Active ? "ON (texture2.jpg)" : "OFF (texture.jpg)"));
      break;
    case 'r': case 'R':
      // Reset semua variabel ke nilai awal
      pitch = radians(-15); yaw = 0; roll = 0;
      crabX = 0; pedY = 0;
      scaleFactor = 1.0;
      lightX_scene = 0; lightY_scene = -height / 4; lightZ_scene = 200;
      isTexture2Active = false; 
      println("Posisi, rotasi, zoom, cahaya, dan tekstur direset.");
     
      resetActiveKeys();
      break;
  }
}

// --- Fungsi untuk menangani pelepasan tombol ---
void keyReleased() {
  if (keyCode == UP) pitchUpActive = false;
  else if (keyCode == DOWN) pitchDownActive = false;
  else if (keyCode == LEFT) yawLeftActive = false;
  else if (keyCode == RIGHT) yawRightActive = false;

  switch(key) {
    case 'a': case 'A': rollLeftActive = false; break;
    case 'd': case 'D': rollRightActive = false; break;
    case 'q': case 'Q': crabLeftActive = false; break;
    case 'e': case 'E': crabRightActive = false; break;
    case 'w': case 'W': pedestalUpActive = false; break;
    case 's': case 'S': pedestalDownActive = false; break;
    case '+': case '=': zoomInActive = false; break;
    case '-': case '_': zoomOutActive = false; break;
    case 'j': case 'J': lightMoveLeftActive = false; break;
    case 'l': case 'L': lightMoveRightActive = false; break;
    case 'i': case 'I': lightMoveUpActive = false; break;
    case 'k': case 'K': lightMoveDownActive = false; break;
    case 'u': case 'U': lightMoveBackwardActive = false; break;
    case 'o': case 'O': lightMoveForwardActive = false; break;
  }
}

// --- Fungsi pembantu untuk mereset semua variabel boolean active key ---
void resetActiveKeys() {
  pitchUpActive = pitchDownActive = yawLeftActive = yawRightActive = rollLeftActive = rollRightActive = false;
  crabLeftActive = crabRightActive = pedestalUpActive = pedestalDownActive = false;
  zoomInActive = zoomOutActive = false;
  lightMoveLeftActive = lightMoveRightActive = lightMoveUpActive = lightMoveDownActive = lightMoveForwardActive = lightMoveBackwardActive = false;
}

// --- Fungsi bantu untuk menulis teks HUD dan menggeser yPos ---
void drawHUDText(String str) {
  text(str, hudXPos, currentHudYPos);
  currentHudYPos += HUD_Y_SPACING;
}

void displayHUD() {
  pushMatrix();
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST);

  // Atur font dan warna teks
  if (statusFont != null) textFont(statusFont, STATUS_FONT_SIZE);
  else textSize(STATUS_FONT_SIZE); 
  fill(255); 

  // Inisialisasi posisi Y untuk HUD pada setiap pemanggilan displayHUD()
  currentHudYPos = 20;

  // --- KONTROL OBJEK (TAHAN TOMBOL) ---
  drawHUDText("KONTROL OBJEK (TAHAN TOMBOL)"); currentHudYPos += HUD_Y_SPACING * 0.5f; // Spasi ekstra
  drawHUDText("Pitch: Panah ATAS/BAWAH");
  drawHUDText("Yaw: Panah KIRI/KANAN");
  drawHUDText("Roll: 'A' / 'D'");
  drawHUDText("Crab (Geser Ki/Ka): 'Q' / 'E'");
  drawHUDText("Pedestal (Geser Atas/Bwh): 'W' / 'S'");
  drawHUDText("Zoom: '+' / '-'");

  // --- KONTROL SEKALI TEKAN ---
  currentHudYPos += HUD_Y_SPACING * 0.5f; 
  drawHUDText("KONTROL SEKALI TEKAN"); currentHudYPos += HUD_Y_SPACING * 0.5f;
  drawHUDText("Tekstur (Toggle ON/OFF): 'T'");
  drawHUDText("Reset All: 'R'");

  // --- KONTROL CAHAYA (TAHAN TOMBOL) ---
  currentHudYPos += HUD_Y_SPACING * 0.5f; 
  drawHUDText("KONTROL CAHAYA"); currentHudYPos += HUD_Y_SPACING * 0.5f;
  drawHUDText("Geser Cahaya X: 'J' / 'L'");
  drawHUDText("Geser Cahaya Y: 'I' / 'K'");
  drawHUDText("Geser Cahaya Z: 'U' / 'O'");

  // --- STATUS ---
  currentHudYPos += HUD_Y_SPACING * 0.5f; // Spasi antar bagian
  drawHUDText("--- STATUS ---"); currentHudYPos += HUD_Y_SPACING * 0.5f;

  String textureStatusText = "Tekstur: ";
  if (isTexture2Active) {
      textureStatusText += "ON (texture2.jpg)";
      if (textureActual == null) textureStatusText += " (GAGAL MUAT!)";
  } else {
      textureStatusText += "OFF (texture.jpg)";
      if (textureSolidColor == null) textureStatusText += " (GAGAL MUAT!)";
  }
  drawHUDText(textureStatusText);

  drawHUDText(String.format("Light Pos: %.0f, %.0f, %.0f", lightX_scene, lightY_scene, lightZ_scene));
  drawHUDText(String.format("Pitch: %.1f°, Yaw: %.1f°, Roll: %.1f°", degrees(pitch), degrees(yaw), degrees(roll)));
  drawHUDText(String.format("CrabX: %.0f, PedY: %.0f, Zoom: %.2fx", crabX, pedY, scaleFactor));

  hint(ENABLE_DEPTH_TEST); 
  popMatrix();
}
