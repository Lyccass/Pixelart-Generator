void draw() {
  background(240);

  if (showEditor) {
    drawGrid();
    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    if (shouldExportImage && exportPath != null) {
      saveCanvasTo(exportPath);
      shouldExportImage = false;
    }

    fill(0);
    textSize(14);
    int valueX = 240;
    int valueY = height / 2 - 100;
    text("Red: " + int(cp5.get(Slider.class, "Red").getValue()), valueX, valueY);
    text("Green: " + int(cp5.get(Slider.class, "Green").getValue()), valueX, valueY + 40);
    text("Blue: " + int(cp5.get(Slider.class, "Blue").getValue()), valueX, valueY + 80);
  }
}
