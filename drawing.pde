void draw() {
  background(240);

  if (showEditor) {
    pushMatrix();
    translate(panOffsetX, panOffsetY);
    scale(zoom);

    drawReferenceImage();
    drawGrid();

    popMatrix();

    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    handleReferenceDragging();

    if (shouldExportImage && exportPath != null) {
      saveCanvasTo(exportPath);
      shouldExportImage = false;
    }

    // Only call this once per frame after layout has settled
    if (!buttonsAdded) {
      setupExportButtons();
      buttonsAdded = true;
    }
  }
}
