void setupMenu() {
  int fieldWidth = 60 * uiScale;
  int fieldHeight = 25 * uiScale;
  int labelSize = 12 * uiScale;
  int spacingX = 150;
  int spacingY = 20;
  int startX = 20;
  int startY = 40;

  PFont font = createFont("Arial", labelSize);

  // Label: COLS
  fill(255, 0, 0);
  textFont(font);
  text("COLS", startX, startY);

  // Textfield: COLS
cp5.addTextfield("colsInput")
  .setPosition(startX, startY + spacingY)
  .setSize(fieldWidth, fieldHeight)
  .setFont(font)
  .setText(str(cols))
  .setAutoClear(false)
  // The next line changes the visible label to "Columns"
  .setCaptionLabel("Columns")  
  .getCaptionLabel().setColor(color(0));

cp5.addTextfield("rowsInput")
  .setPosition(startX + spacingX, startY + spacingY)
  .setSize(fieldWidth, fieldHeight)
  .setFont(font)
  .setText(str(rows))
  .setAutoClear(false)
  // The next line changes the visible label to "Rows"
  .setCaptionLabel("Rows")
  .getCaptionLabel().setColor(color(0));

  // Start Button
  cp5.addButton("Start_Editor")
     .setPosition(startX + spacingX * 2, startY + spacingY)
     .setSize(120 * uiScale, 30 * uiScale)
     .setCaptionLabel("Resize and new Grid");
     
     
     
     
}


void controlEvent(ControlEvent e) {
  if (e.isFrom(cp5.getController("Start_Editor"))) {
    int newCols = constrain(int(cp5.get(Textfield.class, "colsInput").getText()), 8, 128);
    int newRows = constrain(int(cp5.get(Textfield.class, "rowsInput").getText()), 8, 128);
    cols = newCols;
    rows = newRows;
    startEditor();
  }
}


void startEditor() {
  println("Resize and new Grid");
  println("Grid size:", cols, "x", rows);

  undoStack.clear();
  redoStack.clear();

  gridWidth = cols * tileSize;
  gridHeight = rows * tileSize;
  gridOffsetX = (width - gridWidth) / 2;
  gridOffsetY = (height - gridHeight) / 2 - 50;

  // Reset layers and related lists
  layers.clear();
  layerVisibility.clear();
  layerOpacities.clear(); // <-- this was missing!

  for (int i = 0; i < layerCount; i++) {
    PGraphics pg = createGraphics(gridWidth, gridHeight);
    pg.beginDraw();
    pg.clear(); // Transparent background
    pg.endDraw();

    layers.add(pg);
    layerVisibility.add(true);   // All layers visible
    layerOpacities.add(1.0);     // All layers fully opaque
  }

  activeLayer = 0;

  // Remove old sliders
  for (int i = 0; i < 10; i++) {
    cp5.remove("Opacity_Layer_" + i);
  }

  // Rebuild layer opacity sliders
  setupOpacitySliders();

  // If you're no longer using pixelGrid, you can delete this block:
  pixelGrid = new color[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      pixelGrid[x][y] = color(255, 255, 255, 0);
    }
  }

  setupColorPicker();
  showEditor = true;
}


// UI Setup Enhancements
void drawUIStatus() {
  int boxWidth = 320;
  int boxHeight = 420;
  int infoX = width - boxWidth - 40;
  int infoY = 40;
  int padding = 15;
  int lineHeight = 24;

  fill(255, 240);
  stroke(180);
  strokeWeight(1);
  rect(infoX - padding, infoY - padding, boxWidth, boxHeight, 12);

  fill(0);
  textSize(18);
  textAlign(LEFT, TOP);
  int textX = infoX;
  int y = infoY;

  // === Section: Status ===
  text("Status", textX, y); y += lineHeight;
  text("Tool: " + (eraserMode ? "Eraser (E)" : "Brush (E)"), textX, y); y += lineHeight;
  text("Mirror: " + (mirrorMode ? "ON (M)" : "OFF (M)"), textX, y); y += lineHeight;
  text("Export Alpha: " + (exportTransparent ? "Transparent (T)" : "Opaque (T)"), textX, y); y += lineHeight * 2;

  // === Section: Layers ===
  text("Layer Info", textX, y); y += lineHeight;
  text("Active Layer: " + (activeLayer + 1) + " / " + layers.size(), textX, y); y += lineHeight;
  text("Visible: " + (layerVisibility.get(activeLayer) ? "Yes" : "No") + " (Shift+L)", textX, y); y += lineHeight;
  text("Opacity: " + nf(layerOpacities.get(activeLayer), 1, 2), textX, y); y += lineHeight * 2;

  // === Section: Shortcuts ===
  text("Shortcuts", textX, y); y += lineHeight;
  text("[Z] Undo        [X] Redo", textX, y); y += lineHeight;
  text("[S] Save JSON   [L] Load", textX, y); y += lineHeight;
  text("[P] Export PNG  [T] Toggle Alpha", textX, y); y += lineHeight;
  text("[G] Toggle Grid [M] Mirror Mode", textX, y); y += lineHeight;
  text("[E] Toggle Eraser", textX, y); y += lineHeight;
text("Layer ↑↓: Arrow Keys", textX, y); y += lineHeight;

}

// UI Buttons at bottom right
void setupExportButtons() {
  int x = width - 350;
  int y = height - 450;
  int w = 280;
  int h = 50;
  int spacing = 60;

  cp5.addButton("Export_PNG")
     .setPosition(x, y)
     .setSize(w, h)
     .setCaptionLabel("Export PNG")
     .onClick(e -> exportAsPNG());

  cp5.addButton("Export_Animation")
     .setPosition(x, y + spacing)
     .setSize(w, h)
     .setCaptionLabel("Export Animation")
     .onClick(e -> exportLayersAsAnimation());

  cp5.addButton("Export_Layer")
     .setPosition(x, y + spacing*2)
     .setSize(w, h)
     .setCaptionLabel("Export Layer")
     .onClick(e -> exportSingleLayerPrompt(activeLayer));
}
