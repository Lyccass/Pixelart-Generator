String exportPath = null;
boolean shouldExportImage = false;

void exportAsPNG() {
  selectOutput("Choose where to save PNG:", "onExportPathSelected");
}

void onExportPathSelected(File selection) {
  if (selection != null) {
    exportPath = selection.getAbsolutePath();
    if (!exportPath.toLowerCase().endsWith(".png")) {
      exportPath += ".png";
    }
    shouldExportImage = true;
  } else {
    println("Export cancelled.");
  }
}


void saveCanvasTo(String path) {
  println("Saving PNG to: " + path);

  // SAFER: Use default renderer (JAVA2D) unless you *really* need P2D
  PGraphics pg = createGraphics(gridWidth, gridHeight);  // Default is JAVA2D

  pg.beginDraw();

  if (exportTransparent) {
    pg.clear();  // Full transparency
  } else {
    pg.background(255);  // Opaque white
  }

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      color c = pixelGrid[x][y];

      // ⛔ If transparency is OFF, force full opacity
      if (!exportTransparent) {
        c = color(red(c), green(c), blue(c), 255);
      }

      // ✅ Only draw visible pixels (non-zero alpha)
      if (alpha(c) > 0) {
        pg.noStroke();
        pg.fill(c);
        pg.rect(x * tileSize, y * tileSize, tileSize, tileSize);
      }
    }
  }

  pg.endDraw();

  // Optional sanity check:
  // pg.fill(255, 0, 0, 255);
  // pg.rect(0, 0, 100, 100);  // Uncomment if nothing appears!

  pg.save(path);
  println("Export complete!");
}
