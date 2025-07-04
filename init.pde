// --- FILE: settings_and_setup.pde ---

void settings() {
  size(displayWidth, displayHeight, P2D);  // You can switch to JAVA2D if P2D crashes
}

void setup() {
  surface.setLocation(0, 0);
  surface.setResizable(true);
  surface.setTitle("Pixel Painter");

  cp5 = new ControlP5(this);
  PFont font = createFont("Arial", 14);
  textFont(font);
  cp5.setFont(font);

  setupMenu(); // show the input fields + button

  // Simulate what Start_Editor would do:
  cols = constrain(cols, 8, 64);
  rows = constrain(rows, 8, 64);
  startEditor();  // now canvas + editor loads immediately
  
  for (int i = 0; i < 10; i++) {
  recentColors.add(color(0)); // fully black
}


  println("Setup complete.");
}
