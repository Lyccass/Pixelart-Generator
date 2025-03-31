void saveGrid() {
  selectOutput("Choose location to save grid:", "saveGridToFile");
}

void saveGridToFile(File selection) {
  if (selection == null) {
    println("Save cancelled.");
    return;
  }

  JSONObject json = new JSONObject();
  JSONArray layersArray = new JSONArray();

  // Loop through all layers and save their pixel data
  for (int i = 0; i < layers.size(); i++) {
    JSONArray rowsArray = new JSONArray();
    layers.get(i).loadPixels(); // Load pixels to access them

    for (int y = 0; y < rows; y++) {
      JSONArray row = new JSONArray();
      for (int x = 0; x < cols; x++) {
        int index = y * cols + x;
        color c = layers.get(i).pixels[index];
        row.append(hex(c));  // Store as hex string
      }
      rowsArray.append(row);
    }

    layersArray.append(rowsArray); // Append the layer's pixel data
  }

  json.setJSONArray("layers", layersArray);
  json.setInt("cols", cols);
  json.setInt("rows", rows);
  json.setInt("tileSize", tileSize);

  String filePath = selection.getAbsolutePath();
  if (!filePath.toLowerCase().endsWith(".json")) {
    filePath += ".json";
  }

  saveJSONObject(json, filePath); // Save as JSON
  println("Grid with multiple layers saved to: " + filePath);
}

void loadGrid() {
  selectInput("Select a grid file to load:", "loadGridFromFile");
}

void loadGridFromFile(File selection) {
  if (selection == null) {
    println("Load cancelled.");
    return;
  }

  undoStack.clear();  // Clear undo/redo stack
  redoStack.clear();

  String filePath = selection.getAbsolutePath();
  JSONObject json = loadJSONObject(filePath);

  cols = json.getInt("cols");
  rows = json.getInt("rows");
  gridWidth = cols * tileSize;
  gridHeight = rows * tileSize;
  gridOffsetX = (width - gridWidth) / 2;
  gridOffsetY = (height - gridHeight) / 2 - 50;

  JSONArray layersArray = json.getJSONArray("layers");

  // Reset layers
  layers.clear();
  layerVisibility.clear();

  // Load each layer
  for (int i = 0; i < layersArray.size(); i++) {
    PGraphics pg = createGraphics(gridWidth, gridHeight);
    pg.beginDraw();
    pg.clear();

    JSONArray rowsArray = layersArray.getJSONArray(i);
    for (int y = 0; y < rows; y++) {
      JSONArray row = rowsArray.getJSONArray(y);
      for (int x = 0; x < cols; x++) {
        color c = unhex(row.getString(x));
        pg.noStroke();
        pg.fill(c);
        pg.rect(x * tileSize, y * tileSize, tileSize, tileSize);
      }
    }

    pg.endDraw();
    layers.add(pg);
    layerVisibility.add(true); // Set default visibility for all layers
  }

  activeLayer = 0;  // Set default active layer to 0

  println("Multi-layer grid loaded from: " + filePath);
}
