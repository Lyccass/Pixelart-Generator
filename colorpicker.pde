void setupColorPicker() {
  int sliderWidth = 180 * uiScale;
  int sliderHeight = 20 * uiScale;
  int labelSize = 20;
  int startX = 20;
  int startY = height / 2 - 200;
  int spacingY = 50;

  PFont font = createFont("Arial", labelSize);
  if (colorPickerInitialized) return;
  colorPickerInitialized = true;

  // === RED ===
  Slider redSlider = cp5.addSlider("Red")
    .setPosition(startX + 80, startY)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 255)
    .setValue(0)
    .setColorForeground(color(255, 0, 0))
    .setColorBackground(color(100, 0, 0))
    .setColorActive(color(255, 100, 100));
  redSlider.getCaptionLabel().setText("RED").setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
  redSlider.getCaptionLabel().getStyle().marginLeft = -80;
  cp5.getController("Red").onChange(e -> updateHexField());

  // === GREEN ===
  Slider greenSlider = cp5.addSlider("Green")
    .setPosition(startX + 80, startY + spacingY)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 255)
    .setValue(0)
    .setColorForeground(color(0, 255, 0))
    .setColorBackground(color(0, 100, 0))
    .setColorActive(color(100, 255, 100));
  greenSlider.getCaptionLabel().setText("GREEN").setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
  greenSlider.getCaptionLabel().getStyle().marginLeft = -80;
  cp5.getController("Green").onChange(e -> updateHexField());

  // === BLUE ===
  Slider blueSlider = cp5.addSlider("Blue")
    .setPosition(startX + 80, startY + spacingY * 2)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 255)
    .setValue(0)
    .setColorForeground(color(0, 0, 255))
    .setColorBackground(color(0, 0, 100))
    .setColorActive(color(100, 100, 255));
  blueSlider.getCaptionLabel().setText("BLUE").setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
  blueSlider.getCaptionLabel().getStyle().marginLeft = -80;
  cp5.getController("Blue").onChange(e -> updateHexField());

  // === ALPHA ===
  Slider alphaSlider = cp5.addSlider("Alpha")
    .setPosition(startX + 80, startY + spacingY * 3)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 255)
    .setValue(255) // fully opaque by default
    .setColorForeground(color(180))
    .setColorBackground(color(80))
    .setColorActive(color(220));
  alphaSlider.getCaptionLabel().setText("ALPHA").setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
  alphaSlider.getCaptionLabel().getStyle().marginLeft = -80;
  cp5.getController("Alpha").onChange(e -> updateHexField());
  
 


  // === HEX ===
  Textfield hexField = cp5.addTextfield("HexInput")
    .setPosition(startX + 80, startY + spacingY * 4 + 10)
    .setSize(sliderWidth, 30)
    .setAutoClear(false)
    .setText("#000000");
  hexField.getCaptionLabel().setText("HEX").setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
  hexField.getCaptionLabel().getStyle().marginLeft = -70;

  hexField.onChange(e -> {
    String hex = cp5.get(Textfield.class, "HexInput").getText().trim();
    if (hex.startsWith("#")) hex = hex.substring(1);
    try {
      int c = unhex(hex);
      float r = red(c);
      float g = green(c);
      float b = blue(c);

      cp5.get(Slider.class, "Red").setValue(r);
      cp5.get(Slider.class, "Green").setValue(g);
      cp5.get(Slider.class, "Blue").setValue(b);
      // Keep current alpha slider value unchanged
      currentColor = color(r, g, b, cp5.get(Slider.class, "Alpha").getValue());

      println("Hex set to:", hex);
    } catch (Exception ex) {
      println("Invalid hex code:", hex);
    }
  });

  updateHexField();
}

void setupOpacitySliders() {
  int startX = 2350; // ️ Move to the right side
  int startY = 600;
  int spacingY = 50;

  PFont font = createFont("Arial", 14);

  for (int i = 0; i < layers.size(); i++) {
    int y = startY + i * spacingY;

    Slider s = cp5.addSlider("Opacity_Layer_" + i)
      .setPosition(startX, y)
      .setSize(120, 20)
      .setRange(0, 1)
      .setValue(layerOpacities.get(i))
      .setLabel("Layer " + (i + 1) + " Opacity");

    s.getCaptionLabel().setFont(font).setColor(color(0)).align(ControlP5.LEFT, ControlP5.CENTER);
    s.getCaptionLabel().getStyle().marginLeft = -140; // align text to left of slider

    cp5.getController("Opacity_Layer_" + i).onChange(e -> {
      int index = int(split(e.getController().getName(), "_")[2]);
      layerOpacities.set(index, e.getController().getValue());
    });
  }
}


void updateHexField() {
  int r = int(cp5.get(Slider.class, "Red").getValue());
  int g = int(cp5.get(Slider.class, "Green").getValue());
  int b = int(cp5.get(Slider.class, "Blue").getValue());
  int a = int(cp5.get(Slider.class, "Alpha").getValue());

  String hexValue = "#" + hex(color(r, g, b), 6).toUpperCase();
  cp5.get(Textfield.class, "HexInput").setText(hexValue);

  currentColor = color(r, g, b, a); // Update current color including alpha
}
