// --- Variabel Kontrol Gerakan ---
float pitch = 0, yaw = 0, roll = 0;
float rotationRate = 1.0; // Derajat per frame

// Variabel boolean untuk status tombol ditekan (di grup pergerakan)
boolean pitchUpActive, pitchDownActive, yawLeftActive, yawRightActive, rollLeftActive, rollRightActive;
boolean crabLeftActive, crabRightActive, pedestalUpActive, pedestalDownActive;
boolean zoomInActive, zoomOutActive;
boolean lightMoveForwardActive, lightMoveBackwardActive, lightMoveLeftActive, lightMoveRightActive, lightMoveUpActive, lightMoveDownActive;

float crabX = 0, pedY = 0;
float translationRate = 2.0; // Unit per frame
float scaleFactor = 1.0;
float zoomRate = 0.01; // Perubahan skala per frame

// --- Variabel Model 3D & Tekstur ---
PShape akmModel;
boolean isTexture2Active = false; // Default: texture.jpg (warna solid) aktif
PImage textureSolidColor; // Untuk texture.jpg (default / "OFF" state)
PImage textureActual;     // Untuk texture2.jpg ("ON" state)

// --- Variabel Sumber Cahaya ---
float lightX_scene, lightY_scene, lightZ_scene;
float lightMoveRate = 3.0; // Unit per frame

// --- Variabel Lainnya ---
PFont statusFont;
final int STATUS_FONT_SIZE = 16;

void setup() {
  size(1280, 720, P3D); // Inisialisasi ukuran jendela dan mode 3D

  // --- Inisialisasi Font ---
  try {
    statusFont = createFont("Arial", STATUS_FONT_SIZE);
    if (statusFont == null) statusFont = createFont("SansSerif", STATUS_FONT_SIZE);
  } catch (Exception e) {
    println("Error font: " + e.getMessage());
  }

  // --- Muat Model 3D ---
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

  // --- Muat Tekstur ---
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

  // --- Inisialisasi Posisi Awal Objek & Cahaya ---
  pitch = radians(-15); // Kemiringan awal
  lightX_scene = 0;
  lightY_scene = -height / 4;
  lightZ_scene = 200;

  displayControlHints(); // Panggil fungsi ini di sini, sekali saja.
}

// --- Fungsi untuk menampilkan informasi kontrol di konsol ---
void displayControlHints() {
  println("\n--- KONTROL OBJEK (TAHAN TOMBOL) ---");
  println("Pitch: Panah ATAS/BAWAH | Yaw: Panah KIRI/KANAN | Roll: 'A'/'D'");
  println("Crab: 'Q'/'E' | Pedestal: 'W'/'S' | Zoom: '+/-'");
  println("--- KONTROL SEKALI TEKAN ---");
  println("Tekstur (Toggle ON/OFF): 'T' | Reset All: 'R'");
  println("--- KONTROL CAHAYA (TAHAN TOMBOL) ---");
  println("Geser Cahaya X: 'J'/'L' | Y: 'I'/'K' | Z: 'U'/'O'");
  println("------------------------------------");
}


void draw() {
  background(20, 25, 35); // Warna latar belakang gelap

  handleContinuousInput(); // Update pergerakan berdasarkan tombol yang ditekan

  // --- Pengaturan Pencahayaan ---
  ambientLight(100, 100, 110); // Cahaya merata di seluruh scene
  pointLight(255, 250, 240, lightX_scene, lightY_scene, lightZ_scene); // Sumber cahaya titik yang bisa digeser

  // --- Transformasi Kamera/View ---
  translate(width / 2, height / 2, 0); // Pusatkan objek di tengah layar
  translate(crabX, pedY, 0); // Terapkan pergeseran Crab dan Pedestal

  pushMatrix(); // Simpan state transformasi sebelum rotasi/skala objek

  // --- Rotasi dan Skala Objek ---
  rotateZ(roll);
  rotateX(pitch);
  rotateY(yaw);
  scale(scaleFactor);

  drawAKMModel(); // Gambar model dengan tekstur yang sesuai

  popMatrix(); // Kembalikan state transformasi

  displayHUD(); // Tampilkan HUD (informasi kontrol dan status)
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

  akmModel.disableStyle(); // Nonaktifkan style default (dari .mtl) untuk kontrol tekstur manual

  PImage currentTextureToDisplay = null;

  // Tentukan tekstur mana yang akan ditampilkan
  if (isTexture2Active) { // Jika 'ON' (texture2.jpg)
    currentTextureToDisplay = textureActual;
  } else { // Jika 'OFF' (texture.jpg)
    currentTextureToDisplay = textureSolidColor;
  }

  // Terapkan tekstur jika ada, atau tampilkan error jika tidak
  if (currentTextureToDisplay != null) {
    akmModel.setTexture(currentTextureToDisplay);
    akmModel.enableStyle(); // Aktifkan style agar tekstur yang di-setTexture terlihat
  } else {
    fill(255, 0, 0, 180); // Warna merah transparan jika tekstur gagal dimuat
    noStroke();
    println("WARNING: Tekstur gagal dimuat untuk status ini.");
  }

  shape(akmModel); // Gambar objek 3D
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
    case 's': case 'S': pedestalDownActive = true; break; // PERBAIKAN: Ini harus true
    case '+': case '=': zoomInActive = true; break;
    case '-': case '_': zoomOutActive = true; break;
    case 'j': case 'J': lightMoveLeftActive = true; break;
    case 'l': case 'L': lightMoveRightActive = true; break;
    case 'i': case 'I': lightMoveUpActive = true; break;
    case 'k': case 'K': lightMoveDownActive = true; break;
    case 'u': case 'U': lightMoveBackwardActive = true; break;
    case 'o': case 'O': lightMoveForwardActive = true; break;
    case 't': case 'T':
      isTexture2Active = !isTexture2Active; // Toggle status ON/OFF tekstur
      println("Tekstur: " + (isTexture2Active ? "ON (texture2.jpg)" : "OFF (texture.jpg)"));
      break;
    case 'r': case 'R':
      // Reset semua variabel ke nilai awal
      pitch = radians(-15); yaw = 0; roll = 0;
      crabX = 0; pedY = 0;
      scaleFactor = 1.0;
      lightX_scene = 0; lightY_scene = -height / 4; lightZ_scene = 200;
      isTexture2Active = false; // Reset ke default (texture.jpg)
      println("Posisi, rotasi, zoom, cahaya, dan tekstur direset.");
      // Reset semua status active key ke false
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

// --- Fungsi untuk menampilkan informasi kontrol dan status (HUD) ---
void displayHUD() {
  pushMatrix();
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST); // Pastikan HUD digambar di atas semua objek 3D

  if (statusFont != null) textFont(statusFont, STATUS_FONT_SIZE);
  else textSize(STATUS_FONT_SIZE);
  fill(255); // Warna teks putih

  float xPos = 10, yPos = 20, ySpacing = 18;

  // --- Tampilan Kontrol ---
  text("--- KONTROL OBJEK (TAHAN TOMBOL) ---", xPos, yPos); yPos += ySpacing * 1.5f;
  text("Pitch: Panah ATAS/BAWAH", xPos, yPos); yPos += ySpacing;
  text("Yaw: Panah KIRI/KANAN", xPos, yPos); yPos += ySpacing;
  text("Roll: 'A' / 'D'", xPos, yPos); yPos += ySpacing;
  text("Crab (Geser Ki/Ka): 'Q' / 'E'", xPos, yPos); yPos += ySpacing;
  text("Pedestal (Geser Atas/Bwh): 'W' / 'S'", xPos, yPos); yPos += ySpacing;
  text("Zoom: '+' / '-'", xPos, yPos); yPos += ySpacing;

  text("--- KONTROL SEKALI TEKAN ---", xPos, yPos); yPos += ySpacing * 1.5f;
  text("Tekstur (Toggle ON/OFF): 'T'", xPos, yPos); yPos += ySpacing;
  text("Reset All: 'R'", xPos, yPos); yPos += ySpacing * 1.5f;

  text("--- KONTROL CAHAYA (TAHAN TOMBOL) ---", xPos, yPos); yPos += ySpacing * 1.5f;
  text("Geser Cahaya X: 'J' / 'L'", xPos, yPos); yPos += ySpacing;
  text("Geser Cahaya Y: 'I' / 'K'", xPos, yPos); yPos += ySpacing;
  text("Geser Cahaya Z: 'U' / 'O'", xPos, yPos); yPos += ySpacing * 1.5f;

  // --- Tampilan Status ---
  text("--- STATUS ---", xPos, yPos); yPos += ySpacing * 1.5f;
  String textureStatusText = "Tekstur: ";
  if (isTexture2Active) {
      textureStatusText += "ON (texture2.jpg)";
      if (textureActual == null) textureStatusText += " (GAGAL MUAT!)";
  } else {
      textureStatusText += "OFF (texture.jpg)";
      if (textureSolidColor == null) textureStatusText += " (GAGAL MUAT!)";
  }
  text(textureStatusText, xPos, yPos); yPos += ySpacing;

  text(String.format("Light Pos: %.0f, %.0f, %.0f", lightX_scene, lightY_scene, lightZ_scene), xPos, yPos); yPos += ySpacing;
  text(String.format("Pitch: %.1f°, Yaw: %.1f°, Roll: %.1f°", degrees(pitch), degrees(yaw), degrees(roll)), xPos, yPos); yPos += ySpacing;
  text(String.format("CrabX: %.0f, PedY: %.0f, Zoom: %.2fx", crabX, pedY, scaleFactor), xPos, yPos);

  hint(ENABLE_DEPTH_TEST); // Aktifkan kembali depth test
  popMatrix();
}
