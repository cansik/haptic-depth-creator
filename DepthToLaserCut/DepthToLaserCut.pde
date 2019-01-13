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

  checkPixelCount();

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

void checkPixelCount()
{
  if (targetPixelCount != pixelCount)
  {
    resizeImage(targetPixelCount);
    println("Depth Image: " + depthImage.width + ", " + depthImage.height);
  }
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
  /*
  // show debug
   pushMatrix();
   translate(0, 0, modelDepth / 2);
   noFill();
   strokeWeight(2.0f);
   stroke(255);
   box(modelWidth, modelHeight, modelDepth);
   popMatrix();
   */

  // calulate pixel size
  float fullPixelSize = pixelSize + pixelSpace;

  float contentWidth = fullPixelSize * depthImage.width;
  float contentHeight = fullPixelSize * depthImage.height;

  // calculate shifts
  float xShift = (modelWidth - contentWidth) / 2f;
  float yShift = (modelHeight - contentHeight)/ 2f;

  g.translate(xShift, yShift, 0);
  float hpix = fullPixelSize / 2f;

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

      float xpos = x * fullPixelSize - (modelWidth / 2f);
      float ypos = y * fullPixelSize - (modelHeight / 2f);
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

void exportMesh(String name)
{
  //X3DExport obj = (X3DExport) createGraphics(10, 10, "nervoussystem.obj.X3DExport", "colored.x3d");
  OBJExport obj = (OBJExport) createGraphics(10, 10, "nervoussystem.obj.OBJExport", name + ".obj");
  obj.setColor(false);
  obj.beginDraw();
  draw3DModel(obj);
  obj.endDraw();
  obj.dispose();
}


void exportMesh(String name, int pixelCount, float modelDepth, float pixelSpace, float pixelSize)
{
  this.targetPixelCount = pixelCount;
  this.modelDepth = modelDepth;
  this.pixelSpace = pixelSpace;
  this.pixelSize = pixelSize;

  String fullName = name + "-pc" + pixelCount + "-md" + modelDepth + "-ps" + pixelSpace + "-pz" + pixelSize;

  checkPixelCount();
  exportMesh(fullName);
}

void exportPDF()
{
  PGraphicsPDF pdf = (PGraphicsPDF)beginRecord(PDF, "mesh.pdf");
  pdf.setSize(round(mm(900)), round(mm(600)));
  pdf.beginDraw();

  // setup drawing parameters
  strokeWeight(0.1);
  stroke(0);
  noFill();

  // calulate pixel size
  float fullPixelSize = pixelSize + pixelSpace;
  float paddingX = 10;
  float paddingY = 10;

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

      float xpos = paddingX + x *  fullPixelSize;
      float ypos = paddingY + y * fullPixelSize;
      float zpos = map(brightness, 0, 255, 0, modelDepth);

      rect(mm(xpos), mm(ypos), mm(pixelSize), mm(pixelSize));
    }
  }

  pdf.nextPage();


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
