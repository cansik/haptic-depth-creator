import peasy.PeasyCam;

PeasyCam cam;
PImage depthImage;

PShape model = null;

float modelWidth = 300;
float modelHeight = 300;
float modelDepth = 300;

float pixelSize = 3;

void setup()
{
  size(1280, 720, P3D);
  pixelDensity = 2;

  // clipping
  perspective(PI/3.0, (float)width/height, 0.1, 100000);

  cam = new PeasyCam(this, 400);
  cam.setSuppressRollRotationMode();

  depthImage = loadImage("emil_depth.png");
  depthImage.resize(50, 0);

  println("Depth Image: " + depthImage.width + ", " + depthImage.height);
}

void draw()
{
  background(0);

  if (frameCount < 2)
  {
    cam.beginHUD();
    textAlign(CENTER, CENTER);
    text("creating 3d model...", width / 2, height / 2);
    cam.endHUD();
    return;
  }

  if (model == null)
  {
    model = create3DModel();
  }

  // render model
  shape(model);

  // show fps
  cam.beginHUD();
  fill(255);
  textAlign(LEFT, CENTER);
  text("FPS: " + frameRate, 10, 10);
  cam.endHUD();
}

PShape create3DModel()
{
  PShape model = createShape(GROUP);

  int maxSize = max(depthImage.width, depthImage.height);

  depthImage.loadPixels();
  int[] pixels = depthImage.pixels;

  for (int x = 0; x < depthImage.width; x++)
  {
    for (int y = 0; y < depthImage.height; y++)
    {
      println("creating pixel [" + x + ", " + y + "]...");

      // caluclate pixel properties
      color c = pixels[x * y];
      float brightness = brightness(c);

      float xpos = map(x, 0, maxSize, 0, modelWidth);
      float ypos = map(x, 0, maxSize, 0, modelWidth);
      float zpos = map(brightness, 0, 255, 0, modelDepth);

      // create element
      println("translating to: [" + xpos + " " + ypos + "]");
      //model.translate(xpos, ypos, 0);

      PShape box = createShape(BOX, pixelSize, pixelSize, zpos);
      box.fill(255);
      box.setStroke(true);
      box.stroke(255);
      box.strokeWeight(1);

      model.addChild(box);
      //model.resetMatrix();
    }
  }

  return model;
}
