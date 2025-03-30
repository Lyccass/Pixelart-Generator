void saveGrid() {
  selectOutput("Choose location to save grid:", "saveGridToFile");
}

void saveGridToFile(File selection) {
  if (selection == null) {
    println("Save cancelled.");
    return;
  }

  JSONObject json = new JSONObject();
  JSONArray rowsArray = new JSONArray();

  for (int y = 0; y < rows; y++) {
    JSONArray row = new JSONArray();
    for (int x = 0; x < cols; x++) {
      row.append(hex(pixelGrid[x][y]));
    }
    rowsArray.append(row);
  }

  json.setJSONArray("grid", rowsArray);
  json.setInt("cols", cols);
  json.setInt("rows", rows);

  String filePath = selection.getAbsolutePath();
  if (!filePath.toLowerCase().endsWith(".json")) {
    filePath += ".json";
  }

  saveJSONObject(json, filePath);
  println("Grid saved to: " + filePath);
}

void loadGrid() {
  selectInput("Select a grid file to load:", "loadGridFromFile");
}

void loadGridFromFile(File selection) {
  if (selection == null) {
    println("Load cancelled.");
    return;
  }

  undoStack.clear();
  redoStack.clear();

  String filePath = selection.getAbsolutePath();
  JSONObject json = loadJSONObject(filePath);

  cols = json.getInt("cols");
  rows = json.getInt("rows");
  gridWidth = cols * tileSize;
  gridHeight = rows * tileSize;
  gridOffsetX = (width - gridWidth) / 2;
  gridOffsetY = (height - gridHeight) / 2 - 50;

  JSONArray rowsArray = json.getJSONArray("grid");
  pixelGrid = new color[cols][rows];

  for (int y = 0; y < rows; y++) {
    JSONArray row = rowsArray.getJSONArray(y);
    for (int x = 0; x < cols; x++) {
      pixelGrid[x][y] = unhex(row.getString(x));
    }
  }

  println("Grid loaded from: " + filePath);
}
