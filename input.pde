void mousePressed() {
  if (!showEditor || isInteractingWithReference) return;

  if (mouseButton == CENTER) {
    isPanning = true;
    lastPanX = mouseX;
    lastPanY = mouseY;
    return;
  }

  // Check if clicked on recent colors
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

  //  Fill vs Paint logic
  if (currentTool == ToolMode.FILL) {
    fillAt(mouseX, mouseY); // <-- calls your flood fill
    return;
  }
  
  if (currentTool == ToolMode.PICKER) {
  color picked = getColorAt(mouseX, mouseY);
  if (picked != -1) {
    cp5.get(Slider.class, "Red").setValue(red(picked));
    cp5.get(Slider.class, "Green").setValue(green(picked));
    cp5.get(Slider.class, "Blue").setValue(blue(picked));
    cp5.get(Slider.class, "Alpha").setValue(alpha(picked));
    currentColor = picked;

    println("Picked color:", hex(picked));
  } else {
    println("Could not pick color.");
  }

  currentTool = ToolMode.DRAW;  // Exit picker mode after one pick
  return;
}


  // Otherwise, regular painting
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

  // Skip painting if we're interacting with the reference image
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

  // === Brush radius control with SHIFT ===
  if (keyPressed && keyCode == SHIFT) {
    brushRadius += scroll > 0 ? -1 : 1;
    brushRadius = constrain(brushRadius, 1, 5);
    println("Brush Radius: " + brushRadius);
    return;
  }

  // === Default zoom ===
  float newZoom = constrain(zoom - scroll * zoomChange, minZoom, maxZoom);

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

  boolean insideGrid = x >= 0 && x < cols && y >= 0 && y < rows;
  if (!insideGrid) return;

  if (!hasSavedThisStroke) {
    saveStateForUndo();
    hasSavedThisStroke = true;
  }

PGraphics layer = layers.get(activeLayer);
layer.beginDraw();

float a = cp5.get(Slider.class, "Alpha").getValue();
color c = color(
  cp5.get(Slider.class, "Red").getValue(),
  cp5.get(Slider.class, "Green").getValue(),
  cp5.get(Slider.class, "Blue").getValue(),
  a
);

for (int dx = -brushRadius + 1; dx < brushRadius; dx++) {
  for (int dy = -brushRadius + 1; dy < brushRadius; dy++) {
    float dist = dist(0, 0, dx, dy);
    if (dist >= brushRadius) continue; // ⛔ skip tiles outside radius

    int px = x + dx;
    int py = y + dy;

    if (px < 0 || px >= cols || py < 0 || py >= rows) continue;

    if (currentTool == ToolMode.ERASER) {
      layer.noStroke();
      layer.fill(255, 255, 255, 0);
      layer.blendMode(REPLACE);
      layer.rect(px * tileSize, py * tileSize, tileSize, tileSize);
      layer.blendMode(BLEND);
    } else {
      layer.noStroke();
      layer.fill(c);
      layer.rect(px * tileSize, py * tileSize, tileSize, tileSize);
    }

    // Mirror
    if (mirrorMode) {
      int mxMirror = cols - 1 - px;
      if (mxMirror != px && mxMirror >= 0 && mxMirror < cols) {
        if (currentTool == ToolMode.ERASER) {
          layer.fill(255, 255, 255, 0);
          layer.blendMode(REPLACE);
          layer.rect(mxMirror * tileSize, py * tileSize, tileSize, tileSize);
          layer.blendMode(BLEND);
        } else {
          layer.fill(c);
          layer.rect(mxMirror * tileSize, py * tileSize, tileSize, tileSize);
        }
      }
    }
  }
}


// Update current color & recent list
if (currentTool != ToolMode.ERASER) {
  currentColor = c;
  if (!recentColors.contains(c)) {
    recentColors.add(0, c);
    if (recentColors.size() > 10) recentColors.remove(10);
  }
}

layer.endDraw();

}

enum ToolMode { DRAW, FILL, ERASER, PICKER }  // add PICKER
ToolMode currentTool = ToolMode.DRAW;


void keyPressed() {
  // --- Skip shortcuts if typing in layer name
  if (cp5.get(Textfield.class, "LayerNameInput") != null &&
      cp5.get(Textfield.class, "LayerNameInput").isFocus()) return;

  // --- Undo/Redo
  if (key == 'z' || key == 'Z') undo();
  if (key == 'x' || key == 'X') redo();

  // --- Mode Toggles ---
if (key == 'd' || key == 'D') {
  if (currentTool == ToolMode.DRAW) currentTool = ToolMode.FILL;
  else currentTool = ToolMode.DRAW;
  println("Tool: " + currentTool);
}

if (key == 'e' || key == 'E') {
  currentTool = ToolMode.ERASER;
  println("Tool: " + currentTool);
}

if (key == 'c' || key == 'C') {
  currentTool = ToolMode.PICKER;
  println("Tool: COLOR PICKER");
}


  // --- Grid / Mirror ---
  if (key == 'g' || key == 'G') {
    showGridLines = !showGridLines;
    println("Grid Lines: " + (showGridLines ? "ON" : "OFF"));
  }

  if (key == 'm' || key == 'M') {
    mirrorMode = !mirrorMode;
    println("Mirror Mode: " + (mirrorMode ? "ON" : "OFF"));
  }

  // --- File Actions ---
  if (key == 's' || key == 'S') saveGrid();
  if (key == 'l') loadGrid();
  if (key == 'k' || key == 'K') exportLayersAsAnimation();
  if (key == 'p' || key == 'P') exportAsPNG();
  if (key == 'o' || key == 'O') exportSingleLayerPrompt(activeLayer);
  if (key == 't' || key == 'T') {
    exportTransparent = !exportTransparent;
    println("Export transparency set to: " + exportTransparent);
  }

  // --- Layer swapping ---
  if (keyCode == UP) moveLayerUp(activeLayer);
  if (keyCode == DOWN) moveLayerDown(activeLayer);

  // --- Reference image ---
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

  if (key == 'L') {
    boolean vis = layerVisibility.get(activeLayer);
    layerVisibility.set(activeLayer, !vis);
    println("Layer " + (activeLayer + 1) + " visibility: " + !vis);
  }
}

color getColorAt(int mx, int my) {
  float worldX = (mx - panOffsetX) / zoom;
  float worldY = (my - panOffsetY) / zoom;

  int px = int(worldX);
  int py = int(worldY);

  // Option A: Sample from reference image if visible
  if (showReference && referenceImage != null) {
    int refW = int(referenceImage.width * refScale);
    int refH = int(referenceImage.height * refScale);
    if (px >= refX && px < refX + refW && py >= refY && py < refY + refH) {
      int rx = int((px - refX) / refScale);
      int ry = int((py - refY) / refScale);
      if (rx >= 0 && rx < referenceImage.width && ry >= 0 && ry < referenceImage.height) {
        return referenceImage.get(rx, ry);
      }
    }
  }

  // Option B: Composite all visible layers into a temp surface
  PGraphics composite = createGraphics(gridWidth, gridHeight);
  composite.beginDraw();
  composite.clear();
  for (int i = 0; i < layers.size(); i++) {
    if (layerVisibility.get(i)) {
      composite.tint(255, layerOpacities.get(i) * 255);
      composite.image(layers.get(i), 0, 0);
    }
  }
  composite.endDraw();

  // Sample from the composite image
  if (px >= 0 && px < gridWidth && py >= 0 && py < gridHeight) {
    return composite.get(px, py);
  }

  return -1;
}
