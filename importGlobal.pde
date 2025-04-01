import controlP5.*;
import processing.data.JSONArray;
import processing.data.JSONObject;
import java.util.Stack;
import java.util.Collections;


ControlP5 cp5;

int cols = 64;
int rows = 64;
int tileSize = 10;

int gridWidth, gridHeight;
int gridOffsetX, gridOffsetY;

color[][] pixelGrid;
color currentColor = color(0);
ArrayList<Integer> recentColors = new ArrayList<Integer>();



Stack<EditorState> undoStack = new Stack<>();
Stack<EditorState> redoStack = new Stack<>();




boolean colorPickerInitialized = false;
PGraphics canvasLayer;

boolean showEditor = false;
boolean mouseDown = false;
boolean hasSavedThisStroke = false;
boolean showGridLines = true;
boolean mirrorMode = false;
boolean exportTransparent = false;

int uiScale = 2;
int swatchSize = 30 * uiScale;

float zoom = 1.0;
float minZoom = 0.2;
float maxZoom = 5.0;

float panOffsetX = 0;
float panOffsetY = 0;

float lastPanX = 0;
float lastPanY = 0;

boolean isPanning = false;


ArrayList<PGraphics> layers = new ArrayList<PGraphics>();
ArrayList<Boolean> layerVisibility = new ArrayList<Boolean>();

int activeLayer = 0;
int layerCount = 3; // You can increase this later
int singleLayerToExport = -1;
ArrayList<Float> layerOpacities = new ArrayList<Float>();

boolean buttonsAdded = false;
boolean fillMode = false;

int brushRadius = 1; // Default radius
