

void drawGrid() {
  canvasLayer.beginDraw();
  canvasLayer.clear(); // clears with transparent bg

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      color c = pixelGrid[x][y];
      if (alpha(c) == 0) continue; // skip fully transparent

      canvasLayer.noStroke();
      canvasLayer.fill(c);
      canvasLayer.rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }

  canvasLayer.endDraw();

  // Draw the canvas to screen
  image(canvasLayer, gridOffsetX, gridOffsetY);

  // Grid lines on top (optional)
  if (showGridLines) {
    stroke(200);
    for (int x = 0; x <= cols; x++) {
      line(gridOffsetX + x * tileSize, gridOffsetY, gridOffsetX + x * tileSize, gridOffsetY + gridHeight);
    }
    for (int y = 0; y <= rows; y++) {
      line(gridOffsetX, gridOffsetY + y * tileSize, gridOffsetX + gridWidth, gridOffsetY + y * tileSize);
    }
  }
}



void drawRecentColors() {
  fill(0);
  textSize(14 * uiScale);
  text("Recent Colors:", gridOffsetX, gridOffsetY + gridHeight + 35);

  int swatchY = gridOffsetY + gridHeight + 70;

  for (int i = 0; i < recentColors.size(); i++) {
    int swatchX = gridOffsetX + i * (swatchSize + 10);
    fill(recentColors.get(i));
    stroke(0);
    rect(swatchX, swatchY, swatchSize, swatchSize);
  }
}


void drawCurrentColorPreview() {
  float r = cp5.get(Slider.class, "Red").getValue();
  float g = cp5.get(Slider.class, "Green").getValue();
  float b = cp5.get(Slider.class, "Blue").getValue();
  float a = cp5.get(Slider.class, "Alpha").getValue();

  color preview = color(r, g, b, a);

  int previewX = 40;
  int previewY = 250; // Adjust based on layout
  int previewW = 100;
  int previewH = 40;

  fill(preview);
  stroke(0);
  rect(previewX, previewY, previewW, previewH);

  fill(0);
  textSize(16);
  textAlign(LEFT, BOTTOM);
  text("Preview", previewX, previewY - 10);
}
