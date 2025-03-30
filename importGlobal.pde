import controlP5.*;
import processing.data.JSONArray;
import processing.data.JSONObject;
import java.util.Stack;

ControlP5 cp5;

int cols = 32;
int rows = 32;
int tileSize = 20;

int gridWidth, gridHeight;
int gridOffsetX, gridOffsetY;

color[][] pixelGrid;
color currentColor = color(0);
ArrayList<Integer> recentColors = new ArrayList<Integer>();

Stack<color[][]> undoStack = new Stack<color[][]>();
Stack<color[][]> redoStack = new Stack<color[][]>();

boolean colorPickerInitialized = false;
PGraphics canvasLayer;

boolean showEditor = false;
boolean mouseDown = false;
boolean hasSavedThisStroke = false;
boolean eraserMode = false;
boolean showGridLines = true;
boolean mirrorMode = false;
boolean exportTransparent = false;

int uiScale = 2;
int swatchSize = 30 * uiScale;
