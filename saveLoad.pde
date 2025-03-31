void saveGrid() {
  selectOutput("Choose location to save grid:", "saveGridToFile");
}

void saveGridToFile(File selection) {
  if (selection == null) return;

  JSONObject json = new JSONObject();
  JSONArray layersArray = new JSONArray();
  JSONArray visArray = new JSONArray();
  JSONArray opacityArray = new JSONArray();

  for (int i = 0; i < layers.size(); i++) {
    PGraphics pg = layers.get(i);
    pg.loadPixels();

    JSONArray layerData = new JSONArray();
    for (int y = 0; y < rows; y++) {
      JSONArray row = new JSONArray();
      for (int x = 0; x < cols; x++) {
        int px = x * tileSize;
        int py = y * tileSize;
        int idx = py * gridWidth + px;

        color c = pg.pixels[idx];
        if (alpha(c) == 0) {
          row.append("TRANSPARENT");
        } else {
          row.append(hex(c));
        }
      }
      layerData.append(row);
    }

    layersArray.append(layerData);
    visArray.append(layerVisibility.get(i));
    opacityArray.append(layerOpacities.get(i));
  }

  json.setJSONArray("layers", layersArray);
  json.setJSONArray("visibility", visArray);
  json.setJSONArray("opacity", opacityArray);
  json.setInt("cols", cols);
  json.setInt("rows", rows);
  json.setInt("tileSize", tileSize);
  json.setInt("activeLayer", activeLayer);

  String filePath = selection.getAbsolutePath();
  if (!filePath.toLowerCase().endsWith(".json")) {
    filePath += ".json";
  }

  saveJSONObject(json, filePath);
  println("✅ Saved to:", filePath);
}


void loadGrid() {
  selectInput("Select a grid file to load:", "loadGridFromFile");
}

void loadGridFromFile(File selection) {
  if (selection == null) {
    println("Load cancelled.");
    return;
  }

  String filePath = selection.getAbsolutePath();
  JSONObject json = loadJSONObject(filePath);

  cols = json.getInt("cols");
  rows = json.getInt("rows");
  tileSize = json.getInt("tileSize", 20); // fallback
  gridWidth = cols * tileSize;
  gridHeight = rows * tileSize;
  gridOffsetX = (width - gridWidth) / 2;
  gridOffsetY = (height - gridHeight) / 2 - 50;

  JSONArray layersArray = json.getJSONArray("layers");
  JSONArray visArray = json.getJSONArray("visibility");
  JSONArray opacityArray = json.getJSONArray("opacity");

  layers.clear();
  layerVisibility.clear();
  layerOpacities.clear();

  for (int i = 0; i < layersArray.size(); i++) {
    PGraphics pg = createGraphics(gridWidth, gridHeight);
    pg.beginDraw();
    pg.clear();

    JSONArray layerData = layersArray.getJSONArray(i);
    for (int y = 0; y < rows; y++) {
      JSONArray row = layerData.getJSONArray(y);
      for (int x = 0; x < cols; x++) {
        String val = row.getString(x);
        if (!val.equals("TRANSPARENT")) {
          color c = unhex(val);
          pg.noStroke();
          pg.fill(c);
          pg.rect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
      }
    }

    pg.endDraw();
    layers.add(pg);
    layerVisibility.add(visArray.getBoolean(i));
    layerOpacities.add(opacityArray.getFloat(i));
  }

  activeLayer = json.getInt("activeLayer", 0);
  println("✅ Loaded grid from: " + filePath);

  setupOpacitySliders();
}
