void draw() {
  background(240);

  if (showEditor) {
    pushMatrix();
    translate(panOffsetX, panOffsetY);
    scale(zoom);

    drawReferenceImage();   // ← inside canvas
    drawGrid();             // ← over image

    popMatrix();

    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    handleReferenceDragging(); // ← after popMatrix (screen space)
  }
}
