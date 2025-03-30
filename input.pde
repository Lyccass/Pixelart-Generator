void mousePressed() {
  if (!showEditor) return;

  // ✅ Match swatch Y-pos from drawRecentColors()
  for (int i = 0; i < recentColors.size(); i++) {
    int sx = gridOffsetX + i * (swatchSize + 10);
    int sy = gridOffsetY + gridHeight + 70;  // ← was 40 before!

    if (mouseX >= sx && mouseX <= sx + swatchSize &&
        mouseY >= sy && mouseY <= sy + swatchSize) {

      color c = recentColors.get(i);
      cp5.get(Slider.class, "Red").setValue(red(c));
      cp5.get(Slider.class, "Green").setValue(green(c));
      cp5.get(Slider.class, "Blue").setValue(blue(c));
      cp5.get(Slider.class, "Alpha").setValue(alpha(c));  // ← add this if you're using alpha!
      currentColor = c;

      println("Selected recent color:", hex(c));
      return;
    }
  }

  // Painting starts
  mouseDown = true;
  hasSavedThisStroke = false;
  paintAt(mouseX, mouseY);
}



void mouseReleased() {
  mouseDown = false;
  hasSavedThisStroke = false;
}

void mouseDragged() {
  if (!showEditor || !mouseDown) return;
  paintAt(mouseX, mouseY);
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




void paintAt(int mx, int my) {
  int x = (mx - gridOffsetX) / tileSize;
  int y = (my - gridOffsetY) / tileSize;

  boolean insideGrid =
    x >= 0 && x < cols &&
    y >= 0 && y < rows &&
    mx >= gridOffsetX && my >= gridOffsetY &&
    mx < gridOffsetX + gridWidth && my < gridOffsetY + gridHeight;

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
