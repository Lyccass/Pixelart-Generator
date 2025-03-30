

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
  text("Recent Colors:", gridOffsetX, gridOffsetY + gridHeight + 30);
  for (int i = 0; i < recentColors.size(); i++) {
    int x = gridOffsetX + i * (swatchSize + 10);
    int y = gridOffsetY + gridHeight + 40;
    fill(recentColors.get(i));
    stroke(0);
    rect(x, y, swatchSize, swatchSize);
  }
}

void drawCurrentColorPreview() {
  float r = cp5.get(Slider.class, "Red").getValue();
  float g = cp5.get(Slider.class, "Green").getValue();
  float b = cp5.get(Slider.class, "Blue").getValue();
  color preview = color(r, g, b);
  fill(preview);
  stroke(0);
  rect(40, height - 80, 100, 40);
  fill(0);
  textSize(16);
  text("Current", 40, height - 90);
  
}
