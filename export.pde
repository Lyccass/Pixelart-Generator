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

  PGraphics pg = createGraphics(gridWidth, gridHeight);  // Use default renderer

  pg.beginDraw();

  if (exportTransparent) {
    pg.clear();  // Transparent background
  } else {
    pg.background(255);  // Opaque white
  }

  // ✅ Draw all visible layers onto export image
  for (int i = 0; i < layers.size(); i++) {
    if (layerVisibility.get(i)) {
      pg.image(layers.get(i), 0, 0);
    }
  }

  pg.endDraw();

  pg.save(path);
  println("Export complete!");
}
