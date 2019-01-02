import controlP5.*;

ControlP5 cp5;

int uiHeight;

boolean isUIInitialized = false;

void setupUI()
{
  isUIInitialized = false;
  PFont font = createFont("Helvetica", 100f);

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  // change the original colors
  cp5.setColorForeground(color(255, 132, 124));
  cp5.setColorBackground(color(42, 54, 59));
  cp5.setFont(font, 14);
  cp5.setColorActive(color(255, 132, 124));

  int h = 10;
  cp5.addLabel("Model")
    .setPosition(10, h);

  h += 25;
  cp5.addSlider("targetPixelCount", 10, 150, 10, h, 100, 20)
    .setRange(5, 100)
    .setNumberOfTickMarks(64)
    .showTickMarks(false)
    .setLabel("Pixel Count");

  h += 25;
  cp5.addSlider("modelDepth", 10, 150, 10, h, 100, 20)
    .setRange(0, 500)
    .setNumberOfTickMarks(11)
    .showTickMarks(false)
    .setLabel("Model Depth");

  h += 25;
  cp5.addSlider("pixelSpace", 10, 150, 10, h, 100, 20)
    .setRange(1, 10)
    .setNumberOfTickMarks(10)
    .showTickMarks(false)
    .setLabel("Pixel Space");

  h += 50;
  cp5.addLabel("Histogram")
    .setPosition(10, h);

  h += 25;
  cp5.addSlider("histogramStart", 10, 150, 10, h, 100, 20)
    .setRange(0, 255)
    .setNumberOfTickMarks(64)
    .showTickMarks(false)
    .setLabel("Start");

  h += 25;
  cp5.addSlider("histogramEnd", 10, 150, 10, h, 100, 20)
    .setRange(0, 255)
    .setNumberOfTickMarks(64)
    .showTickMarks(false)
    .setLabel("End");

  uiHeight = h + 200;

  isUIInitialized = true;
}

public String formatTime(long millis)
{
  long second = (millis / 1000) % 60;
  long minute = (millis / (1000 * 60)) % 60;
  long hour = (millis / (1000 * 60 * 60)) % 24;

  if (minute == 0 && hour == 0 && second == 0)
    return String.format("%02dms", millis);

  if (minute == 0 && hour == 0)
    return String.format("%02ds", second);

  if (hour == 0)
    return String.format("%02dm %02ds", minute, second);

  return String.format("%02dh %02dm %02ds", hour, minute, second);
}

void mousePressed() {

  // suppress cam on UI
  if (mouseX > 0 && mouseX < 200 && mouseY > 0 && mouseY < uiHeight) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
}
