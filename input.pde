void mousePressed() {
    if (!showEditor || isInteractingWithReference) return;

  if (mouseButton == CENTER) {
    // Start panning
    isPanning = true;
    lastPanX = mouseX;
    lastPanY = mouseY;
    return;
  }

  // --- Check if clicked on recent color swatches ---
  int swatchesPerRow = 5;
  int startX = 40;
  int startY = height / 2 + 260;

  for (int i = 0; i < recentColors.size(); i++) {
    int col = i % swatchesPerRow;
    int row = i / swatchesPerRow;
    int sx = startX + col * (swatchSize + 10);
    int sy = startY + row * (swatchSize + 10);

    if (mouseX >= sx && mouseX <= sx + swatchSize &&
        mouseY >= sy && mouseY <= sy + swatchSize) {
      color c = recentColors.get(i);
      cp5.get(Slider.class, "Red").setValue(red(c));
      cp5.get(Slider.class, "Green").setValue(green(c));
      cp5.get(Slider.class, "Blue").setValue(blue(c));
      cp5.get(Slider.class, "Alpha").setValue(alpha(c));
      currentColor = c;

      println("Selected recent color:", hex(c));
      return;
    }
  }

  // Start drawing
  mouseDown = true;
  hasSavedThisStroke = false;
  paintAt(mouseX, mouseY);
}

void mouseDragged() {
  if (!showEditor) return;

  if (isPanning) {
    float dx = mouseX - lastPanX;
    float dy = mouseY - lastPanY;
    panOffsetX += dx;
    panOffsetY += dy;
    lastPanX = mouseX;
    lastPanY = mouseY;
    return;
  }

  // ⛔ Skip painting if we're interacting with the reference image
  if (isInteractingWithReference) return;

  if (mouseDown) {
    paintAt(mouseX, mouseY);
  }
}


void mouseReleased() {
  isPanning = false;
  mouseDown = false;
  hasSavedThisStroke = false;
}


void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  float zoomChange = 0.05;

  float newZoom = constrain(zoom - scroll * zoomChange, minZoom, maxZoom);

  // Zoom towards mouse position
  float mouseWorldX = (mouseX - panOffsetX) / zoom;
  float mouseWorldY = (mouseY - panOffsetY) / zoom;

  panOffsetX -= (mouseWorldX * newZoom - mouseWorldX * zoom);
  panOffsetY -= (mouseWorldY * newZoom - mouseWorldY * zoom);

  zoom = newZoom;
}


void paintAt(int mx, int my) {
  float worldX = (mx - panOffsetX) / zoom;
  float worldY = (my - panOffsetY) / zoom;

  int x = int((worldX - gridOffsetX) / tileSize);
  int y = int((worldY - gridOffsetY) / tileSize);

  boolean insideGrid =
    x >= 0 && x < cols &&
    y >= 0 && y < rows;

  if (!insideGrid) return;

  if (!hasSavedThisStroke) {
    saveStateForUndo();
    hasSavedThisStroke = true;
  }

  PGraphics layer = layers.get(activeLayer);
  layer.beginDraw();

  if (eraserMode) {
    // Transparent erase using REPLACE mode
    layer.noStroke();
    layer.fill(255, 255, 255, 0);
    layer.blendMode(REPLACE);
    layer.rect(x * tileSize, y * tileSize, tileSize, tileSize);
    layer.blendMode(BLEND);
  } else {
    float a = cp5.get(Slider.class, "Alpha").getValue();
    color c = color(
      cp5.get(Slider.class, "Red").getValue(),
      cp5.get(Slider.class, "Green").getValue(),
      cp5.get(Slider.class, "Blue").getValue(),
      a
    );
    layer.noStroke();
    layer.fill(c);
    layer.rect(x * tileSize, y * tileSize, tileSize, tileSize);
    currentColor = c;

    if (!recentColors.contains(c)) {
      recentColors.add(0, c);
      if (recentColors.size() > 10) recentColors.remove(10);
    }
  }

  layer.endDraw();

  // Mirror mode support
  if (mirrorMode) {
    int mxMirror = cols - 1 - x;
    if (mxMirror != x && mxMirror >= 0 && mxMirror < cols) {
      paintAt((int)((mxMirror * tileSize + gridOffsetX) * zoom + panOffsetX), my);
    }
  }
}




void keyPressed() {
  // --- Editing Tools ---
  if (key == 'z' || key == 'Z') undo();
  if (key == 'x' || key == 'X') redo();
  if (key == 'e' || key == 'E') eraserMode = !eraserMode;
  if (key == 'g' || key == 'G') showGridLines = !showGridLines;
  if (key == 'm' || key == 'M') mirrorMode = !mirrorMode;

  // --- File Actions ---
  if (key == 's' || key == 'S') saveGrid();
  if (key == 'l' ) loadGrid();
  if (key == 'p' || key == 'P') exportAsPNG();
  if (key == 't' || key == 'T') {
    exportTransparent = !exportTransparent;
    println("Export transparency set to: " + exportTransparent);
  }

  // --- Reference Image Controls ---
  if (key == 'i' || key == 'I') loadReferenceImage();
  if (key == 'v' || key == 'V') showReference = !showReference;
  if (key == DELETE || key == BACKSPACE) referenceImage = null;
  if (key == 'r' || key == 'R') {
    refX = 100;
    refY = 100;
    refScale = 1.0;
  }
  if (key == 'y' || key == 'Y') {
    imageLocked = !imageLocked;
    println("Reference image locked: " + imageLocked);
  }

  // --- Layer Controls ---
  if (key >= '1' && key <= '9') {
    int index = key - '1';
    if (index < layers.size()) {
      activeLayer = index;
      println("Switched to layer: " + (activeLayer + 1));
    }
  }

  if (key == 'L') { // Shift+L toggles visibility of current layer
    boolean vis = layerVisibility.get(activeLayer);
    layerVisibility.set(activeLayer, !vis);
    println("Layer " + (activeLayer + 1) + " visibility: " + !vis);
  }
}
