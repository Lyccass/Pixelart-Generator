void mousePressed() {
  if (!showEditor) return;

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
  // Convert screen space to world space
  float worldX = (mx - panOffsetX) / zoom;
  float worldY = (my - panOffsetY) / zoom;

  int x = int((worldX - gridOffsetX) / tileSize);
  int y = int((worldY - gridOffsetY) / tileSize);

  boolean insideGrid =
    x >= 0 && x < cols &&
    y >= 0 && y < rows;

  if (insideGrid) {
    if (!hasSavedThisStroke) {
      saveStateForUndo();
      hasSavedThisStroke = true;
    }

    float a = cp5.get(Slider.class, "Alpha").getValue();
    color c = eraserMode ? color(255, 255, 255, 0) : color(
      cp5.get(Slider.class, "Red").getValue(),
      cp5.get(Slider.class, "Green").getValue(),
      cp5.get(Slider.class, "Blue").getValue(),
      a
    );

    currentColor = c;
    pixelGrid[x][y] = c;

    if (mirrorMode) {
      int mxMirror = cols - 1 - x;
      if (mxMirror != x && mxMirror >= 0 && mxMirror < cols) {
        pixelGrid[mxMirror][y] = c;
      }
    }

    if (!recentColors.contains(c) && !eraserMode) {
      recentColors.add(0, c);
      if (recentColors.size() > 10) recentColors.remove(10);
    }
  }
}


void keyPressed() {
  if (key == 'z' || key == 'Z') undo();
  if (key == 'x' || key == 'X') redo();
  if (key == 'e' || key == 'E') eraserMode = !eraserMode;
  if (key == 'g' || key == 'G') showGridLines = !showGridLines;
  if (key == 'm' || key == 'M') mirrorMode = !mirrorMode;
  if (key == 's' || key == 'S') saveGrid();
  if (key == 'l' || key == 'L') loadGrid();
  if (key == 'p' || key == 'P') exportAsPNG();
  if (key == 't' || key == 'T') {
    exportTransparent = !exportTransparent;
    println("Export transparency set to: " + exportTransparent);
  }
}
