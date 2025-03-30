void saveStateForUndo() {
  color[][] snapshot = new color[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      snapshot[x][y] = pixelGrid[x][y];
    }
  }
  undoStack.push(snapshot);
  if (undoStack.size() > 30) undoStack.remove(0);
  redoStack.clear();
}

void undo() {
  if (!undoStack.empty()) {
    redoStack.push(copyGrid(pixelGrid));
    pixelGrid = undoStack.pop();
  }
}

void redo() {
  if (!redoStack.empty()) {
    undoStack.push(copyGrid(pixelGrid));
    pixelGrid = redoStack.pop();
  }
}

color[][] copyGrid(color[][] original) {
  color[][] copy = new color[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      copy[x][y] = original[x][y];
    }
  }
  return copy;
}
