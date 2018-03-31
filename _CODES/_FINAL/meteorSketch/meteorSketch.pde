/*
  Author            : Cesar R. Urteaga-Reyesvera.
  Creation date     : March 29, 2018.
*/

//-------------------------------------------------------------------- LIBRARIES
// Imports the library in order to save the final image into pdf format.
import processing.pdf.*;

//------------------------------------------------------------- GLOBAL VARIABLES
// Withholds the SVG map.
PShape BaseMap;
// Holds the contents of the CSV file into an array.
String CSV[];
// Defines a two-dimension array.
String MeteoriteData[][];
// Holds a font variable.
PFont LabelFont;

//-------------------------------------------------------------------- CONSTANTS
// Establishes the considered period.
final int BaselineDate = 1900;
final int BoundDate = 2012;
final int TopMeteorites = 24;
// Markers' features.
final float MarkerScaleFactor = 0.02;
final int LowestColor = 150;
final int HighestColor = 240;
final int Transparency = 50;

//------------------------------------------------------------------------ SETUP
/*
  N.B.: In this section, the code only runs once.  Basically, this block of code
        is used to establish the canvas's traits and initialize the global
        variables.
*/
void setup() {
  /* Establishes the width and height of the pdf canvas in pixels.
     N.B.: The equirectangular map projection is always going to be twice as
     wide as it is tall.
  */

  size(1800, 900);
  /* Disables the implicit loop of the draw section so as to depict the images
     once.
  */
  noLoop();

  // Set the used font type up.
  LabelFont = createFont("Times New Roman", 12);

  // Load both the SVG and CSV files.
  BaseMap = loadShape("../../../_DATA/_RAW/WorldMap.svg");
  CSV = loadStrings("../../../_DATA/_RAW/MeteorStrikes.csv");

  // Save the CSV data into a two-dimesion array.
  MeteoriteData = new String[CSV.length - 1][6];
  for(int i = 1; i < CSV.length; i++) {
    MeteoriteData[i - 1] = CSV[i].split(",");
  }
}

//------------------------------------------------------------------------- DRAW
void draw() {
  beginRecord(PDF, "../../../_GRAPHS/_FINAL/MeteorStrikes.pdf");
    // We add the map into the canvas as to its dimensions.
    shape(BaseMap, 0, 0, width, height);

    // We set the color space.
    colorMode(HSB, 360, 100, 100, 100);

    // Depicts the color scale into the map.
    for(int i = LowestColor; i < HighestColor; i++) {
      noStroke();
      fill(i, 100, 100);
      rect((i - LowestColor) * 3 + 80, 700, 3, 20);
    }
    fill(0);
    text("Strike date", 80, 700 - 3);
    text(str(BaselineDate), 80, 700 + 32);
    text(str(BoundDate), 3 * (HighestColor - LowestColor) + 50, 700 + 32);

    // Displays the link of the Github's repository.
    text("Project's files: https://github.com/Cesar-Urteaga/1803_PROCESSING_METEORITES",
         width - 500, height - 5);

    // Based on the CSV data, we draw each meteorite strike.
    int j = 0;
    for(int i = 0; i < MeteoriteData.length; i++) {
      // Enables the font.
      textMode(MODEL);
      // Turns the shapes' line borders off.
      noStroke();

      int Year = int(MeteoriteData[i][1]);
      /*
        Since we want that pi * (diameter / 2) ^ 2  = weight, then
        diameter = 2 * sqrt(weight / pi)

        N.B.: We have scaled the diameter each circle by a scale factor.
      */
      float MarkerDiameter = MarkerScaleFactor * 2 *
                             sqrt(float(MeteoriteData[i][2]) / PI);
      float Longitude = map(float(MeteoriteData[i][3]), -180, 180, 0, width);
      float Latitude = map(float(MeteoriteData[i][4]), 90, -90, 0, height);

      // Only plots the meteorites occured in the stated period.
      if(Year >= BaselineDate && Year <= BoundDate) {
        fill(map(Year, BaselineDate, BoundDate, LowestColor, HighestColor),
             100, 100, Transparency);
        ellipse(Longitude, Latitude, MarkerDiameter, MarkerDiameter);
        j++;

        // Labels the top meteorites by weight.
        if(j <= TopMeteorites) {
          // Text labels
          fill(0);
          textFont(LabelFont);
          text(MeteoriteData[i][0], Longitude + MarkerDiameter + 4, Latitude + 4);
          // Reference lines
          stroke(0);
          line(Longitude + MarkerDiameter / 2, Latitude,
               Longitude + MarkerDiameter, Latitude);
        }
      }
    }
  endRecord();
  println("PDF Saved");
}
