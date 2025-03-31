void drawGrid() {
  // 0. Optional: solid white background for all layers (like export opaque mode)
  if (!exportTransparent) {
    noStroke();
    fill(255); // white
    rect(gridOffsetX, gridOffsetY, gridWidth, gridHeight);
  }

  // 1. Draw all visible layers with opacity
  for (int i = 0; i < layers.size(); i++) {
    if (layerVisibility.get(i)) {
      float alpha = layerOpacities.get(i); // Range: 0.0 to 1.0
      tint(255, 255 * alpha);
      image(layers.get(i), gridOffsetX, gridOffsetY);
      noTint(); // Reset tint after each layer
    }
  }

  // 2. Optional: draw grid lines over everything
  if (showGridLines) {
    stroke(200);
    for (int x = 0; x <= cols; x++) {
      line(gridOffsetX + x * tileSize, gridOffsetY,
           gridOffsetX + x * tileSize, gridOffsetY + gridHeight);
    }
    for (int y = 0; y <= rows; y++) {
      line(gridOffsetX, gridOffsetY + y * tileSize,
           gridOffsetX + gridWidth, gridOffsetY + y * tileSize);
    }
  }
}



void drawRecentColors() {
  int swatchesPerRow = 5;
  int startX = 40;
  int startY = height / 2 + 260;
  int spacing = 10;

  int totalRows = ceil(recentColors.size() / float(swatchesPerRow));
  int boxWidth = swatchesPerRow * (swatchSize + spacing) - spacing;
  int boxHeight = totalRows * (swatchSize + spacing) - spacing;

  // Background box
  fill(255);
  stroke(180);
  rect(startX - 20, startY - 80, boxWidth + 40, boxHeight + 100, 10);

  fill(0);
  textSize(14 * uiScale);
  text("Recent Colors:", startX, startY - 50);

  for (int i = 0; i < recentColors.size(); i++) {
    int col = i % swatchesPerRow;
    int row = i / swatchesPerRow;
    int x = startX + col * (swatchSize + spacing);
    int y = startY + row * (swatchSize + spacing);

    fill(recentColors.get(i));
    stroke(0);
    rect(x, y, swatchSize, swatchSize);
  }
}



void drawCurrentColorPreview() {
  float r = cp5.get(Slider.class, "Red").getValue();
  float g = cp5.get(Slider.class, "Green").getValue();
  float b = cp5.get(Slider.class, "Blue").getValue();
  float a = cp5.get(Slider.class, "Alpha").getValue();

  color preview = color(r, g, b, a);

  int previewX = 20;
  int previewY = 400; // Adjust based on layout
  int previewW = 100;
  int previewH = 40;

  fill(preview);
  stroke(0);
  rect(previewX, previewY, previewW, previewH);

  fill(0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Current Color", previewX, previewY - 10);
}


void moveLayerUp(int index) {
  if (index >= 0 && index < layers.size() - 1) {
    swapLayers(index, index + 1);
    activeLayer = index + 1;
  }
}

void moveLayerDown(int index) {
  if (index > 0 && index < layers.size()) {
    swapLayers(index, index - 1);
    activeLayer = index - 1;
  }
}

void swapLayers(int i, int j) {
  Collections.swap(layers, i, j);
  Collections.swap(layerVisibility, i, j);
  Collections.swap(layerOpacities, i, j);
  // Optionally: swap layer names if you're using those
}

void drawLayerOverlay() {
  float infoX = gridOffsetX;
  float infoY = gridOffsetY - 90; // slightly above grid

  fill(255, 240);
  stroke(150);
  rect(infoX, infoY, 180, 70, 10); // Rounded background

fill(255, 0, 0);
text("Layer " + (activeLayer + 1) + " / " + layers.size(), infoX + 10, infoY + 8);

fill(0);  // back to black
text("Visible: " + (layerVisibility.get(activeLayer) ? "Yes" : "No"), infoX + 10, infoY + 26);
text("Opacity: " + nf(layerOpacities.get(activeLayer), 1, 2), infoX + 10, infoY + 42);

}
