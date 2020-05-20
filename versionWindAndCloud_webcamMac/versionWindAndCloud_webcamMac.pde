/**
/* POUR LE MODE FULL-SCREEN : menu SKETCH->PRESENT
 **/

import processing.video.*;

Capture video;
boolean cheatScreen;
int numCam=0;

// All ASCII characters, sorted according to their visual density
String letterOrder =
" .`-_':,;^=+/\"|)\\<>)iv%xclrs{*}I?!][1taeo7zjLu" +
"nT#JCwfy325Fp6mqSghVd4EgXPGZbYkOA&8U$@KHDBWNMR0Q";
char[] letters;

float[] bright;
char[] chars;

PFont font;
float fontSize = 1;
float fontSize2 = 1;
int mIndex=0;
PGraphics pg;



public void setup() {
  //size(1024, 768, P3D);
  // Or run full screen, more fun! Use with Sketch -> Present
  size(800, 600, P3D);
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, 80, 60);
  // Start capturing the images from the camera
  video.start();  
  int count = video.width * video.height;

  font = loadFont("automat-24.vlw");

  // for the 256 levels of brightness, distribute the letters across
  // the an array of 256 elements to use for the lookup
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }

  // current characters for each position in the video
  chars = new char[count];

  // current brightness for each point
  bright = new float[count];
  for (int i = 0; i < count; i++) {
    // set each brightness at the midpoint to start
    bright[i] = 128;
  }
}


public void captureEvent(Capture c) {
  c.read();
}


void draw() {

  background(0);

  pushMatrix();

  float hgap = width / float(video.width);
  float vgap = height / float(video.height);

  scale(max(hgap, vgap) * fontSize);
  //textFont(font, fontSize);

  int index = 0;
    video.loadPixels();
  for (int y = 1; y < video.height; y++) {

    // Move down for next line
    translate(0, 1.0 / fontSize);

    pushMatrix();
    for (int x = 0; x < video.width; x++) {
      int pixelColor = video.pixels[index];
      // Faster method of calculating r, g, b than red(), green(), blue() 
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      // Another option would be to properly calculate brightness as luminance:
      // luminance = 0.3*red + 0.59*green + 0.11*blue
      // Or you could instead red + green + blue, and make the the values[] array
      // 256*3 elements long instead of just 256.
      int pixelBright = max(r, g, b);
      pixelBright = int(.3*r+.59*r+.11*r);
      // The 0.1 value is used to damp the changes so that letters flicker less
      float diff = pixelBright - bright[index];
      bright[index] += diff * 0.1;

      fill(pixelColor);
      int num = int(bright[index]);
      fontSize2 =  bright[index]/(64.);
      //textFont(font, fontSize2/1.5);
      textFont(font, fontSize*pixelBright/128.0);
      pushMatrix();

      //rotateY(pixelBright/128);
      translate(0.0, 0.0, pixelBright/(-diff));
      text(letters[num], 0, 0, sqrt(pixelBright/8.0));
      //println(pixelBright);

      popMatrix();
      // Move to the next pixel
      index++;
      translate(1./fontSize, 0, 0);
    }
    popMatrix();
  }
  popMatrix();
  // saveFrame();
}


/**
 * Handle key presses:
 * 'c' toggles the cheat screen that shows the original image in the corner
 * 'g' grabs an image and saves the frame to a tiff image
 * 'f' and 'F' increase and decrease the font size
 */
public void keyPressed() {
  switch (key) {
  case 'g': 
    saveFrame(); 
    break;
  case 'f': 
    fontSize *= 1.1; 
    break;
  case 'F': 
    fontSize *= 0.9; 
    break;
  }
}

