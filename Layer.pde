void setupLayerControls() {
  int x = width - 350;
  int y = height - 240; // above export buttons
  int w = 280;
  int h = 50;
  int spacing = 60;

  cp5.addButton("Add_Layer")
   .setPosition(x, y)
   .setSize(w, h)
   .setCaptionLabel("+ Add Layer")
   .onClick(e -> {
     if (layers.size() < 9) {
       addNewLayer();
     } else {
       println("Layer limit reached (9).");
     }
   });


  cp5.addButton("Remove_Layer")
     .setPosition(x, y + spacing)
     .setSize(w, h)
     .setCaptionLabel("- Remove Layer")
     .onClick(e -> removeActiveLayer());
}

void addNewLayer() {
  PGraphics pg = createGraphics(gridWidth, gridHeight);
  pg.beginDraw();
  pg.clear();
  pg.endDraw();

  layers.add(pg);
  layerVisibility.add(true);
  layerOpacities.add(1.0);
  activeLayer = layers.size() - 1;

  setupOpacitySliders(); // Rebuild sliders
  println("Added new layer: " + layers.size());
}

void removeActiveLayer() {
  if (layers.size() <= 1) {
    println("Cannot remove the last layer.");
    return;
  }

  layers.remove(activeLayer);
  layerVisibility.remove(activeLayer);
  layerOpacities.remove(activeLayer);
  removeAllOpacitySliders(); // Clears previous ones
  setupOpacitySliders();     // Adds fresh ones

  activeLayer = max(0, activeLayer - 1); // move to previous layer if possible
  setupOpacitySliders(); // Rebuild sliders
  println("Removed active layer. Now active: " + (activeLayer + 1));
}

void removeAllOpacitySliders() {
  for (int i = 0; i < 20; i++) {
    String name = "Opacity_Layer_" + i;
    if (cp5.getController(name) != null) {
      cp5.remove(name);
    }
  }
}
