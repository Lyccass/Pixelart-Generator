PImage referenceImage;
float refX = 100;
float refY = 100;
boolean draggingRef = false;
float refOffsetX, refOffsetY;
boolean showReference = true;  // Toggle with a key?

float refScale = 1.0;
boolean overImage = false;
boolean overResizeCorner = false;
boolean resizingRef = false;
boolean isInteractingWithReference = false;
boolean imageLocked = false;



float resizeCornerSize = 16; // size of draggable corner box


void loadReferenceImage() {
  selectInput("Select reference image:", "onReferenceImageSelected");
}

void onReferenceImageSelected(File selection) {
  if (selection == null) {
    println("No image selected.");
    return;
  }
  referenceImage = loadImage(selection.getAbsolutePath());
  println("Reference image loaded:", selection.getAbsolutePath());
}

void drawReferenceImage() {
  if (showReference && referenceImage != null) {
    pushMatrix();
    translate(refX, refY);
    scale(refScale);

    image(referenceImage, 0, 0);

    // Outline
    stroke(0);
    noFill();
    rect(0, 0, referenceImage.width, referenceImage.height);

    // Only show resize handle if image is not locked
    if (!imageLocked) {
      fill(255);
      rect(referenceImage.width - resizeCornerSize, referenceImage.height - resizeCornerSize,
           resizeCornerSize, resizeCornerSize);
    }

    // Draw lock status label
    fill(0, 180);
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(imageLocked ? " Locked (press L to unlock)" : " Drag & Resize (press L to lock)", 5, -5);

    popMatrix();
  }
}



void handleReferenceDragging() {
  if (!showEditor || referenceImage == null) return;
  if (!showEditor || referenceImage == null || imageLocked) {
      isInteractingWithReference = false;
      return;
      }

  float mouseWorldX = (mouseX - panOffsetX) / zoom;
  float mouseWorldY = (mouseY - panOffsetY) / zoom;

  float localX = (mouseWorldX - refX) / refScale;
  float localY = (mouseWorldY - refY) / refScale;

  boolean isOverImage = localX >= 0 && localX <= referenceImage.width &&
                        localY >= 0 && localY <= referenceImage.height;

  boolean isOverCorner = isOverImage &&
                         localX >= referenceImage.width - resizeCornerSize &&
                         localY >= referenceImage.height - resizeCornerSize;

  // === Only set dragging or resizing on first mouse press ===
 isInteractingWithReference = false;

if (!draggingRef && !resizingRef && mousePressed && mouseButton == LEFT) {
  if (isOverCorner) {
    resizingRef = true;
  } else if (isOverImage) {
    draggingRef = true;
    refOffsetX = localX;
    refOffsetY = localY;
  }
}

// While actively resizing
if (resizingRef) {
  float scaleX = localX / referenceImage.width;
  float scaleY = localY / referenceImage.height;
  float newScale = min(scaleX, scaleY);
  refScale = lerp(refScale, constrain(newScale, 0.1, 10.0), 0.3);
  isInteractingWithReference = true;
}

// While actively dragging
if (draggingRef) {
  refX = mouseWorldX - refOffsetX * refScale;
  refY = mouseWorldY - refOffsetY * refScale;
  isInteractingWithReference = true;
}

// On mouse release
if (!mousePressed) {
  draggingRef = false;
  resizingRef = false;
}
}
