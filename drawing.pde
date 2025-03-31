void draw() {
  background(240);

  if (showEditor) {
    pushMatrix();
    translate(panOffsetX, panOffsetY);
    scale(zoom);

    drawReferenceImage();  //  First: image goes right above background
    drawGrid();           //  Then: grid + painted pixels draw on to
    popMatrix();

    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    handleReferenceDragging();

    if (shouldExportImage && exportPath != null) {
      saveCanvasTo(exportPath);
      shouldExportImage = false;
    }
  }
}
