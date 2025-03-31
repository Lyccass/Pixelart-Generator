class EditorState {
  PImage[] snapshots;
  int activeLayer;

  EditorState(PImage[] snapshots, int activeLayer) {
    this.snapshots = snapshots;
    this.activeLayer = activeLayer;
  }
}



void saveStateForUndo() {
  PImage[] snapshot = new PImage[layers.size()];
  for (int i = 0; i < layers.size(); i++) {
    snapshot[i] = layers.get(i).get();
  }
  undoStack.push(new EditorState(snapshot, activeLayer));
  if (undoStack.size() > 30) undoStack.remove(0);
  redoStack.clear();
}



void undo() {
  if (!undoStack.empty()) {
    // Save current state to redo stack
    PImage[] current = new PImage[layers.size()];
    for (int i = 0; i < layers.size(); i++) {
      current[i] = layers.get(i).get();
    }
    redoStack.push(new EditorState(current, activeLayer));

    // Apply last state
    EditorState state = undoStack.pop();
    activeLayer = state.activeLayer;
    for (int i = 0; i < state.snapshots.length; i++) {
      layers.get(i).beginDraw();
      layers.get(i).clear();
      layers.get(i).image(state.snapshots[i], 0, 0);
      layers.get(i).endDraw();
    }
  }
}


void redo() {
  if (!redoStack.empty()) {
    // Save current state to undo stack
    PImage[] current = new PImage[layers.size()];
    for (int i = 0; i < layers.size(); i++) {
      current[i] = layers.get(i).get();
    }
    undoStack.push(new EditorState(current, activeLayer));

    // Apply redo state
    EditorState state = redoStack.pop();
    activeLayer = state.activeLayer;
    for (int i = 0; i < state.snapshots.length; i++) {
      layers.get(i).beginDraw();
      layers.get(i).clear();
      layers.get(i).image(state.snapshots[i], 0, 0);
      layers.get(i).endDraw();
    }
  }
}
