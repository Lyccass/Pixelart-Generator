void draw() {
  background(240);

  if (showEditor) {
    drawGrid();
    drawRecentColors();
    drawCurrentColorPreview();
    drawUIStatus();

    if (shouldExportImage && exportPath != null) {
      saveCanvasTo(exportPath);
      shouldExportImage = false;
    }
   
  }
}
