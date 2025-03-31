void saveStateForUndo() {
  PImage[] snapshot = new PImage[layers.size()];
  for (int i = 0; i < layers.size(); i++) {
    snapshot[i] = layers.get(i).get(); // make a deep copy of the layer
  }
  undoStack.push(snapshot);
  if (undoStack.size() > 30) undoStack.remove(0);
  redoStack.clear();
}

void undo() {
  if (!undoStack.empty()) {
    PImage[] current = new PImage[layers.size()];
    for (int i = 0; i < layers.size(); i++) {
      current[i] = layers.get(i).get();
    }
    redoStack.push(current);

    PImage[] snapshot = undoStack.pop();
    for (int i = 0; i < snapshot.length; i++) {
      layers.get(i).beginDraw();
      layers.get(i).clear(); // in case the snapshot is smaller
      layers.get(i).image(snapshot[i], 0, 0);
      layers.get(i).endDraw();
    }
  }
}

void redo() {
  if (!redoStack.empty()) {
    PImage[] current = new PImage[layers.size()];
    for (int i = 0; i < layers.size(); i++) {
      current[i] = layers.get(i).get();
    }
    undoStack.push(current);

    PImage[] snapshot = redoStack.pop();
    for (int i = 0; i < snapshot.length; i++) {
      layers.get(i).beginDraw();
      layers.get(i).clear();
      layers.get(i).image(snapshot[i], 0, 0);
      layers.get(i).endDraw();
    }
  }
}
