import processing.video.*;

// Global variables for input selection and data
String[] cameras;
Capture cam;
PImage mov;
PImage inputImage;
boolean inputMethodSelected = false;
int startTime;
int frame;
Character[][] charac;
int dropsLength;
int ScreenWidth = 1280;
int ScreenHeight = 720;
int threshold = 128;
String TextRain = "Text Rain is an interactive installation in which participants use the familiar instrument of their bodies";
char[] inputCharacter;
int dupStrings = 10;

void loadFrame() {
  int newFrame = 1 + (millis() - startTime)/100; // get new frame every 0.1 sec
  if (newFrame == frame)
    return;
  frame = newFrame;
  String movieName = "TextRainInput";
  String filePath = movieName + "/" + nf(frame,3) + ".jpg";
  mov = loadImage(filePath);
  if (mov == null) {
    startTime = millis();
    loadFrame();
  }
}

void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
   charac = new Character[dupStrings][TextRain.length()];//[TextRain.length()];
  int inc = ScreenWidth/TextRain.length();
  int spawnPos = 5;
  inputCharacter = new char[TextRain.length()];
  for (int i = 0; i < TextRain.length(); i++) {
    inputCharacter[i] = TextRain.charAt(i);
  }
  int addLineHeight = 0;
  for (int i = 0; i < dupStrings; i++) {
    for (int j = 0; j < inputCharacter.length; j++) {
      Character testLetter = new Character(inputCharacter[j]);
      testLetter.x = spawnPos;
      testLetter.y-= addLineHeight; 
      charac[i][j] = testLetter;
      spawnPos += random(inc);
      if (spawnPos >= ScreenWidth-inc) {
        spawnPos = 5; 
      }
    }
    addLineHeight += 50;
  }
  dropsLength = TextRain.length();
}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from the image sequence or from a live camera feed. Store the result in the inputImage variable
  if (cam != null) {
    if (cam.available())
      cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
  }
  else if (mov != null) {
    loadFrame();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }
  PImage destination= createImage(inputImage.width, inputImage.height, RGB);
  
  inputImage.loadPixels();
  destination.loadPixels();
  
  for (int x = 0; x < inputImage.width; x++) {
    for (int y = 0; y < inputImage.height; y++ ) {
      int loc = x + y*inputImage.width;
      // Test the brightness against the threshold
      if (brightness(inputImage.pixels[loc]) > threshold) {
        destination.pixels[loc]  = color(255);  // White
      }  else {
        destination.pixels[loc]  = color(0);    // Black
      }
    }
  }

  // We changed the pixels in destination
  destination.updatePixels();
  set(0, 0, destination);
      for (int i = 0; i < dupStrings; i++) {
        for (int j = 0; j < dropsLength; j++) {
          
          
      if (charac[i][j].y < ScreenHeight && charac[i][j].y > 0) {    
        int loc = charac[i][j].x + (charac[i][j].y*ScreenWidth);
        float bright = brightness(inputImage.pixels[loc]);
        if (bright > threshold) {
          charac[i][j].y=charac[i][j].y+int(random(1,4));
       if (charac[i][j].y > 720) {
       charac[i][j].alpha -= 5;
       if(charac[i][j].alpha <= 0) {
        charac[i][j].y = int(random(-350, 0));
        charac[i][j].alpha = 255; 
          charac[i][j].MoveUp = 1;}}
        }
        else {
          if (charac[i][j].y > 0) {
            int aboveLoc = loc = charac[i][j].x + ((charac[i][j].y)-1)*ScreenWidth;
            float aboveBright = brightness(inputImage.pixels[aboveLoc]);
            if (aboveBright < threshold) {
               int newY =  charac[i][j].y - charac[i][j].MoveUp;
               if (newY >= 0) {
                 charac[i][j].y = newY;
               }
               else {
                 charac[i][j].y = 0;
               }
              newY = charac[i][j].y - charac[i][j].MoveUp;
              if (newY >= 0) {
              charac[i][j].y = newY;
            }
            else {
              charac[i][j].y = 0;
            }
            charac[i][j].MoveUp = charac[i][j].MoveUp * 2;
            }
          }
        }
      }
      else {
        charac[i][j].y=charac[i][j].y+int(random(1,4));
       if (charac[i][j].y > 720) {
       charac[i][j].alpha -= 5;
       if(charac[i][j].alpha <= 0) {
        charac[i][j].y = int(random(-350, 0));
        charac[i][j].alpha = 255; 
    }
    }
      }
      fill(204, 102, 0);
      text(charac[i][j].textLetter,  charac[i][j].x,  charac[i][j].y);
    }
  }
  // Tip: This code draws the current input image to the screen
}


void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        startTime = millis();
        loadFrame();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }

  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      threshold++;
      if(threshold>255){
        threshold=255;
      }
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      threshold--;
      if(threshold<0){
      threshold=0;
      }
    }
  }
  else if (key == ' ') {
    // space bar pressed
  }  
}

class Character {
  int x;
  int y;  
  char textLetter;
  int MoveUp;
  int alpha = 255;
  
  Character(char inputText) {
    x = 0;
    y =int(random(-1050, 0));
    textLetter = inputText;
    textSize(16);
    MoveUp = 1;
  }
}