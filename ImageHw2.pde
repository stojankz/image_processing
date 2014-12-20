//Klementina Stojanovska
//CSE 270M

void setup() {
  int start = millis();
  PImage orig = loadImage("flowers.jpg");

  //Wanted all versions of the picture to show up side by side
  //so I multiplied by the number of times the picture will show up
  size(3*orig.width, orig.height);
  PImage autoContrast = autoContrast(orig);
  PImage autoContrast2 = autoContrast2(orig);

  //Shows each image
  image(orig, 0, 0);
  drawHistogram(orig, 0, 0);
  image(autoContrast, orig.width, 0);
  drawHistogram(autoContrast, orig.width, 0);
  image(autoContrast2, 2*orig.width, 0);
  drawHistogram(autoContrast2, 2*orig.width, 0);


  //gets the total time it took for my program to run
  //and prints it.
  int end = millis();
  int time = end - start;
  println(time);
  
  int[] histogram = getHistogram(orig);
  int i = bRange(histogram);
  System.out.println(i);
}

//Calculations the brightness of a color and returns that
//brightness as a float
float myBrightness(color c) {
  float brightness = (0.2126*red(c) + 0.7152*green(c) + 0.0722*blue(c));
  return brightness;
}

//Returns an int array holding the frequencies of the brightness
//values. For example, if the brightness of a particular pixel was 120, 
//the int[] at position 120 would increase by 1. It goes through a loop
//to get all of the brightness values frequencies.
int[] getHistogram(PImage source) {
  int[] histogramValues = new int[256];
  for (int i = 0; i<source.pixels.length; i++) {
    color c = source.pixels[i];
    int brightValue= (int)myBrightness(c);
    histogramValues[brightValue]++;
  }
  return histogramValues;
}

int bRange(int[] bHist){
  int brightest = Integer.MIN_VALUE;
  int leastBright = Integer.MAX_VALUE;
  
  for(int e: bHist){
    if(e<leastBright) leastBright = e;
    if(e>brightest) brightest = e;
  }
  return brightest - leastBright;
}

//Draws a histogram picture with the top left corner
//located at x and y.
void drawHistogram(PImage source, int x, int y) {
  int histHeight = 102;
  int histWidth = 258;

  //Creates the rectangle with a specified height
  //and width.
  noStroke();
  rect(x, y, histWidth, histHeight);

  int[] histogramValues = getHistogram(source);
  int largestFrequency = max(histogramValues);
  int smallestFrequency = min(histogramValues);
  System.out.println(largestFrequency);
  System.out.println(smallestFrequency);
  stroke(0);

  //Goes through the frequency values in the histogram array
  //and draws a line/bar for each value. This value represents the 
  //brightness frequencies. Each value is drawn relative to the
  //height of the largest frequency. For example, a bar with half
  //the height of the tallest bar indicates that the frequency of 
  //that brightness value is half the frequency of the brightness
  // value that has the tallest.
  for (int i = 0; i< histogramValues.length; i++) {
    int frequency = histogramValues[i];
    int heightOfLine = (int)map(frequency, y, y+largestFrequency, y, y+102);
    int yCoorOfLine = histHeight - heightOfLine;
    int xCoorOfLine = x + (int)map(i, x, x+histogramValues.length, x, x+258);
    line(xCoorOfLine, histHeight, xCoorOfLine, yCoorOfLine);
  }
}

//Finds the least bright pixel and the brightest pixel
//and stretches the pixels out by considering the least bright
//as 0 and the most bright by 255. Then, calculates the scale 
//factor, or how much each pixel is stretched, by dividing
//the new brighness and the actual brightness. Each color 
//component for each pixel is then multiplied by this scale 
//factor to give you a contrasted image.
PImage autoContrast(PImage source) {
  PImage destination = createImage(source.width, source.height, RGB);
  destination.loadPixels();

  int[] frequencies = getHistogram(source);

  //Uses while loops to go through each brightness frequency.
  //Checks to see if the frequency is 0, if it is, it
  //increases the number of least bright and increases the
  //index to check by.
  int leastBright = 0;
  int x = 0;
  while (frequencies[x] == 0) {
    leastBright++;
    x++;
  }
  //Same type of loop is used as above to find the
  //brightest value.
  int brightest = 255;
  int j = 255;
  while (frequencies[j] == 0) {
    brightest--;
    j--;
  }

  //This is the loop that is used to go through all of 
  //the pixels in the image and calculate the new
  //contrasted color for each pixel.
  for (int i = 0; i< source.pixels.length; i++) {
    color c = source.pixels[i];
    float currentBrightness = myBrightness(c);
    float newBrightness = map(currentBrightness, leastBright, 
    brightest, 0, 255);
    float scaleFactor = newBrightness/currentBrightness;

    //EFFICIENCY: I stored these values as ints because ints 
    //take less memory
    int newR = (int)constrain(scaleFactor * red(c), 0, 255);
    int newG = (int)constrain(scaleFactor * green(c), 0, 255);
    int newB = (int)constrain(scaleFactor * blue(c), 0, 255);

    //EFFICIENCY: Instead of calling color(), I used bit shifting
    destination.pixels[i] = newR << 16 |
      newG << 8 |
      newB;
  }

  destination.updatePixels();
  return destination;
}


//This autoContrast2 method essentially does the
//same thing as the method above, except it accounts for the
//fact that a picture may contain 0 and 255 as brightness values 
//and takes out the first 3% and last 3% of the pixels in the
//image. This is done to give a better contrasted picture.
PImage autoContrast2(PImage source) {
  PImage destination = createImage(source.width, source.height, RGB);
  destination.loadPixels();

  //calculate the amount of pixels you want to ignore. In
  //my case, I wanted to ignore the first 3% and last 3%
  int amtIgnore = (int)(source.pixels.length* 0.03);
  int[] frequencies = getHistogram(source);

  //This while loop counts the number of pixels it
  //goes through and stops when the count is greater
  //than the amount of pixels you want to ignore.
  //It increases the count by the number of brightness
  //frequency each time the count is less than the amount
  //you want to ignore.
  int count = 0;
  int leastBright = 0;
  int x = 0;
  while (count < amtIgnore) {
    count = count + frequencies[x];
    leastBright++;
    x++;
  }

  //Same idea in this loop is used as in the loop above.
  //This loop just starts from the brightest values and 
  //goes down to get rid of the last  3% of pixels in the
  //picture. This finds the brightest value.
  count = 0;
  int brightest = 255;
  int j = 255;
  while (count < amtIgnore) {
    count += frequencies[j];
    brightest--;
    j--;
  }

  //This loop is used to go through all of the pixels
  //in the image and calculate the new contrasted color
  //for each pixel.
  for (int i = 0; i< source.pixels.length; i++) {
    color c = source.pixels[i];
    float currentBrightness = myBrightness(c);
    float newBrightness = map(currentBrightness, leastBright, 
    brightest, 0, 255);
    float scaleFactor = newBrightness/currentBrightness;

    //EFFICIENCY: I stored these values as ints because ints 
    //take less memory
    int newR = (int)constrain(scaleFactor * red(c), 0, 255);
    int newG = (int)constrain(scaleFactor * green(c), 0, 255);
    int newB = (int)constrain(scaleFactor * blue(c), 0, 255);

    //EFFICIENCY: Instead of calling color(), I used bit shifting
    destination.pixels[i] = newR << 16 |
      newG << 8 |
      newB;
  }

  destination.updatePixels();
  return destination;
}

