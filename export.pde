String exportPath = null;
boolean shouldExportImage = false;

void exportAsPNG() {
  selectOutput("Choose where to save PNG:", "onExportPathSelected");
}

void exportSingleLayerPrompt(int layerIndex) {
  if (layerIndex < 0 || layerIndex >= layers.size()) return;

  singleLayerToExport = layerIndex;
  selectOutput("Save Layer " + (layerIndex + 1) + " As:", "onSingleLayerExportSelected");
}


void exportLayersAsAnimation() {
  selectFolder("Select folder to export layers:", "onExportLayersFolderSelected");
}

void onExportPathSelected(File selection) {
  if (selection != null) {
    String base = selection.getAbsolutePath();
    if (!base.toLowerCase().endsWith(".png")) {
      base += ".png";
    }

    // Get selected scale from the radio group
    float selectedScale = cp5.get(RadioButton.class, "ExportScaleGroup").getValue();


    // ✅ Append scale suffix and export
    String path = base.replace(".png", "_x" + selectedScale + ".png");
    saveCanvasTo(path, selectedScale);
    
  } else {
    println("Export cancelled.");
  }
}

void saveCanvasTo(String path) {
  saveCanvasTo(path, 1.0);
}

void saveCanvasTo(String path, float scale) {
  int w = int(gridWidth * scale);
  int h = int(gridHeight * scale);

  if (w <= 0 || h <= 0) {
    println("⚠️ Invalid export size: " + w + "x" + h);
    return;
  }

  println("Saving PNG (x" + scale + ") to: " + path);
  PGraphics pg = createGraphics(w, h);
  pg.beginDraw();

  if (exportTransparent) {
    pg.clear();
  } else {
    pg.background(255);
  }

  for (int i = 0; i < layers.size(); i++) {
    if (layerVisibility.get(i)) {
      pg.image(layers.get(i), 0, 0, w, h);  // scaled draw
    }
  }

  pg.endDraw();
  pg.save(path);
  println("✅ Exported: " + path);
}


void exportAllLayersToFolder(String folderPath) {
  for (int i = 0; i < layers.size(); i++) {
    String filename = folderPath + "/layer_" + nf(i + 1, 2) + ".png";
    layers.get(i).save(filename);
    println("Saved: " + filename);
  }
  println("All layers exported to: " + folderPath);
}

void onExportLayersFolderSelected(File folder) {
  if (folder != null) {
    exportAllLayersToFolder(folder.getAbsolutePath());
  } else {
    println("Export cancelled.");
  }
}

void onSingleLayerExportSelected(File selection) {
  if (selection != null && singleLayerToExport >= 0) {
    String path = selection.getAbsolutePath();
    if (!path.toLowerCase().endsWith(".png")) {
      path += ".png";
    }

    exportSingleLayer(singleLayerToExport, path);
    singleLayerToExport = -1; // reset
  } else {
    println("Single layer export cancelled.");
  }
}

void exportSingleLayer(int layerIndex, String path) {
  if (layerIndex < 0 || layerIndex >= layers.size()) return;

  PGraphics layer = layers.get(layerIndex);
  layer.save(path);
  println("Exported layer " + (layerIndex + 1) + " to: " + path);
}

void saveCanvasTo(String basePath, int scaleFactor) {
  println("Saving PNG (x" + scaleFactor + ") to: " + basePath);

  int scaledW = gridWidth * scaleFactor;
  int scaledH = gridHeight * scaleFactor;

  PGraphics pg = createGraphics(scaledW, scaledH);  // Create larger canvas
  pg.beginDraw();

  if (exportTransparent) {
    pg.clear();
  } else {
    pg.background(255);
  }

  // Scale and draw each visible layer
  pg.scale(scaleFactor);  // Scale BEFORE drawing
  for (int i = 0; i < layers.size(); i++) {
    if (layerVisibility.get(i)) {
      pg.image(layers.get(i), 0, 0);
    }
  }

  pg.endDraw();
  pg.save(basePath);
  println(" Exported at scale x" + scaleFactor);
}
