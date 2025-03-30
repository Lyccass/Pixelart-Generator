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
     .setCaptionLabel("Start Editor");
}


void controlEvent(ControlEvent e) {
  if (e.isFrom(cp5.getController("Start_Editor"))) {
    int newCols = constrain(int(cp5.get(Textfield.class, "colsInput").getText()), 8, 64);
    int newRows = constrain(int(cp5.get(Textfield.class, "rowsInput").getText()), 8, 64);
    cols = newCols;
    rows = newRows;
    startEditor();
  }
}


void startEditor() {
  println("Starting editor...");
  println("Grid size:", cols, "x", rows);

  undoStack.clear();
  redoStack.clear();

  gridWidth = cols * tileSize;
  gridHeight = rows * tileSize;
  gridOffsetX = (width - gridWidth) / 2;
  gridOffsetY = (height - gridHeight) / 2 - 50;

  canvasLayer = createGraphics(gridWidth, gridHeight);
  pixelGrid = new color[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      pixelGrid[x][y] = color(255, 255, 255, 0);
    }
  }

  setupColorPicker();
  showEditor = true;
}



void drawUIStatus() {
  int boxWidth = 320;
  int boxHeight = 320;
  int infoX = width - boxWidth - 40;
  int infoY = 40;
  int padding = 15;
  int lineHeight = 24;

  // Draw background box
  fill(255, 240); // Slightly transparent white
  stroke(180);
  strokeWeight(1);
  rect(infoX - padding, infoY - padding, boxWidth, boxHeight, 12); // Rounded corners

  // Set up text styling
  fill(0);
  textSize(18);
  textAlign(LEFT, TOP);
  int textX = infoX;
  int y = infoY;

  // Section: Status
  text("Status", textX, y); y += lineHeight;
  text("Tool: " + (eraserMode ? "Eraser (E)" : "Brush (E)"), textX, y); y += lineHeight;
  text("Mirror: " + (mirrorMode ? "ON (M)" : "OFF (M)"), textX, y); y += lineHeight;
  text("Export Alpha: " + (exportTransparent ? "Transparent (T)" : "Opaque (T)"), textX, y); y += lineHeight * 2;

  // Section: Shortcuts
  text("Shortcuts", textX, y); y += lineHeight;
  text("[Z] Undo        [X] Redo", textX, y); y += lineHeight;
  text("[S] Save JSON   [L] Load", textX, y); y += lineHeight;
  text("[P] Export PNG  [T] Toggle Alpha", textX, y); y += lineHeight;
  text("[G] Toggle Grid [M] Mirror Mode", textX, y); y += lineHeight;
  text("[E] Toggle Eraser", textX, y);
}
