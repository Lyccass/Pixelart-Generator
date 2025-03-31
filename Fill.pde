void fillAt(int mx, int my) {
  float worldX = (mx - panOffsetX) / zoom;
  float worldY = (my - panOffsetY) / zoom;

  int x = int((worldX - gridOffsetX) / tileSize);
  int y = int((worldY - gridOffsetY) / tileSize);

  if (x < 0 || y < 0 || x >= cols || y >= rows) return;

  PGraphics layer = layers.get(activeLayer);

  // Get the color at the tile
  color targetColor = layer.get(x * tileSize + 1, y * tileSize + 1);
  if (targetColor == currentColor) return;

  // Flood-fill using stack
  Stack<PVector> stack = new Stack<PVector>();
  stack.push(new PVector(x, y));

  while (!stack.isEmpty()) {
    PVector p = stack.pop();
    int px = int(p.x);
    int py = int(p.y);

    if (px < 0 || py < 0 || px >= cols || py >= rows) continue;

    color c = layer.get(px * tileSize + 1, py * tileSize + 1);
    if (c != targetColor) continue;

    // Fill the tile
    layer.beginDraw();
    layer.noStroke();
    layer.fill(currentColor);
    layer.rect(px * tileSize, py * tileSize, tileSize, tileSize);
    layer.endDraw();

    // Push neighbors
    stack.push(new PVector(px + 1, py));
    stack.push(new PVector(px - 1, py));
    stack.push(new PVector(px, py + 1));
    stack.push(new PVector(px, py - 1));
  }
}
