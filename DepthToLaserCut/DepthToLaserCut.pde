import peasy.PeasyCam;
import nervoussystem.obj.*;
import processing.pdf.*;

PeasyCam cam;

PImage emilImage;
PImage depthImage;

int pixelCount = 0;
int targetPixelCount = 15;

PShape model = null;

float modelWidth = 300;
float modelHeight = 300;
float modelDepth = 100;

float pixelSpace = 2;
float pixelSize = 4;

boolean showHistogram = false;
boolean autoScalePixelSize = true;

int histogramStart = 0;
int histogramEnd = 255;

void setup()
{
  size(1280, 720, P3D);
  pixelDensity(2);

  // clipping
  perspective(PI/3.0, (float)width/height, 0.1, 100000);

  cam = new PeasyCam(this, 400);

  emilImage = loadImage("emil_depth.png");

  setupUI();
}

void draw()
{
  background(0);

  if (targetPixelCount != pixelCount)
  {
    resizeImage(targetPixelCount);
    println("Depth Image: " + depthImage.width + ", " + depthImage.height);
  }

  draw3DModel(this.g);
  showInformation();
}

void showInformation()
{
  cam.beginHUD();
  cp5.draw();

  fill(255);
  textSize(14);
  String infoText = "FPS: " + frameRate 
    + "\nPixel: [" + (depthImage.width * depthImage.height) + "]";

  text(infoText, 20, height - 40);
  cam.endHUD();
}


void resizeImage(int w)
{
  resizeImage(w, 0);
}

void resizeImage(int w, int h)
{
  pixelCount = w;

  depthImage = emilImage.copy();
  depthImage.resize(w, h);
  depthImage.loadPixels();
}

void draw3DModel(PGraphics g)
{
  // show debug
  /*
  pushMatrix();
   translate(0, 0, modelDepth / 2);
   noFill();
   strokeWeight(2.0f);
   stroke(255);
   box(modelWidth, modelHeight, modelDepth);
   popMatrix();
   */

  int maxSize = max(depthImage.width, depthImage.height);
  float maxLength = max(modelWidth, modelHeight);

  // calulate pixel size
  float spacePerPixel = maxLength / maxSize;
  float fullPixelSize = pixelSize + pixelSpace;

  if (autoScalePixelSize)
  {
    pixelSize = spacePerPixel - pixelSpace;
    fullPixelSize = pixelSize > 0 ? pixelSize + pixelSpace  : spacePerPixel;
    pixelSize = pixelSize > 0 ? pixelSize : spacePerPixel;
    pixelSizeSlider.setValue(pixelSize);
  }

  float contentWidth = fullPixelSize * depthImage.width;
  float contentHeight = fullPixelSize * depthImage.height;

  // calculate shifts
  float xShift = (modelWidth - contentWidth) / 2f;
  float yShift = (modelHeight - contentHeight)/ 2f;

  g.translate(xShift, yShift, 0);
  float hpix = spacePerPixel / 2f;

  for (int x = 0; x < depthImage.width; x++)
  {
    for (int y = 0; y < depthImage.height; y++)
    {
      g.pushMatrix();

      // caluclate pixel properties
      color c = depthImage.get(x, y);
      float b = brightness(c);

      // map brightness for more detail
      float brightness = clampMap(b, histogramStart, histogramEnd, 0, 255);

      float xpos = map(x, 0, maxSize, modelWidth / -2f, modelWidth / 2f);
      float ypos = map(y, 0, maxSize, modelHeight / -2f, modelHeight / 2f);
      float zpos = map(brightness, 0, 255, 0, modelDepth);

      // create element
      g.translate(xpos + hpix, ypos + hpix, zpos / 2);

      g.fill(brightness);
      g.noStroke();
      g.box(pixelSize, pixelSize, zpos);
      g.popMatrix();
    }
  }
}

float clampMap(float x, float s1, float e1, float s2, float e2)
{
  return map(constrain(x, s1, e1), s1, e1, s2, e2);
}

void exportMesh()
{
  OBJExport obj = (OBJExport) createGraphics(10, 10, "nervoussystem.obj.OBJExport", "mesh.obj");
  obj.setColor(true);
  obj.beginDraw();
  draw3DModel(obj);
  obj.endDraw();
  obj.dispose();
}

void exportPDF()
{
  beginRecord(PDF, "mesh.pdf");
  //PGraphicsPDF pdf = (PGraphicsPDF) g; 

  // setup drawing parameters
  strokeWeight(0.1);
  stroke(0);
  noFill();
  
  

  // draw baseplate
  for (int x = 0; x < depthImage.width; x++)
  {
    for (int y = 0; y < depthImage.height; y++)
    {
      // caluclate pixel properties
      color c = depthImage.get(x, y);
      float b = brightness(c);

      // map brightness for more detail
      float brightness = clampMap(b, histogramStart, histogramEnd, 0, 255);

      /*
      float xpos = map(x, 0, maxSize, mm(20), modelWidth);
      float ypos = map(y, 0, maxSize, mm(20), modelHeight);
      float zpos = map(brightness, 0, 255, 0, modelDepth);

      rect(mm(xpos), mm(ypos), mm(pixelSize), mm(pixelSize));
      */
    }
  }

  //pdf.nextPage();


  endRecord();
}

void keyPressed()
{
  switch(key)
  {
  case 'h':
    showHistogram = !showHistogram;
  }
}
