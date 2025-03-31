void draw() {
  background(240);

  if (showEditor) {
    pushMatrix();
    translate(panOffsetX, panOffsetY);
    scale(zoom);

    // ✅ Only grid (or pixel canvas) should be affected by zoom/pan
    drawGrid();

    popMatrix();

    // ✅ Everything else stays static
    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    if (shouldExportImage && exportPath != null) {
      saveCanvasTo(exportPath);
      shouldExportImage = false;
    }
  }
}
