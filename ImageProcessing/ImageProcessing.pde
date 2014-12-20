//Klementina Stojanovska
//12/5/2014
//I chose to do seam carving in image processing.

//For reference to how to calculate the math related
//aspects of this project, I used 
//http://www.cs.princeton.edu/courses/
// archive/spring13/cos226/assignments/seamCarving.html

//For reference on how to do the energy sums using
//dynamic programming I used:
//http://thecreatorsproject.vice.com/blog/
// what-is-seam-carving-an-explanation-and-tutorial-video

//Castle image taken from:
//http://en.wikipedia.org/wiki/Seam_carving

String startImage = "thelouvre.jpg";
void setup() {
  PImage orig = loadImage(startImage);
  size(orig.width, orig.height+60);
}

void draw() {
  background(100);
  PImage orig = loadImage(startImage);
  PImage newImage = orig;
  frame.setSize(newImage.width, newImage.height+ 60);
  textSize(20);
  fill(255);
  text("Click and hold buttons for images.", 
  newImage.width/4, newImage.height/4, newImage.width/2, newImage.height/2);
  drawButtons(newImage);

  //checks if the mouse is clicked over the "Original Photo" button.
  //If it is, shows the original photo
  if (mousePressed == true && mouseX > 0 && mouseX < newImage.width/5 &&
    mouseY > newImage.height) {
    newImage = orig;
    frame.setSize(newImage.width, newImage.height +60);
    image(newImage, 0, 0);
    drawButtons(newImage);
  }
  //checks if the mouse is pressed over the "Energy Photo" button
  //If it is, shows the energy photo
  if (mousePressed == true && mouseX> newImage.width/5 && 
    mouseX < 2*(newImage.width/5) && mouseY > newImage.height) {
    long[][] energyTable = getEnergyTable(orig);
    long max = findMax(energyTable);
    long min = findMin(energyTable);
    newImage = drawEnergyPicture(orig, energyTable, min, max);
    frame.setSize(newImage.width, newImage.height +60);
    image(newImage, 0, 0);
    drawButtons(newImage);
  }
  //checks if the mouse is pressed over the "Energy Sum
  //Photo" button. If it is, shows the energy sum photo
  if (mousePressed == true && mouseX>2*(newImage.width/5) && 
    mouseX< 3*(newImage.width/5) && mouseY > newImage.height) {
    long[][] energyTable = getEnergyTable(orig);
    long[][] smallestEnergySums = shortestPaths(energyTable);
    long sumsMax = findMax(smallestEnergySums);
    long sumsMin = findMin(smallestEnergySums);
    newImage = drawEnergySumsImage(orig, smallestEnergySums, sumsMin, sumsMax);
    frame.setSize(newImage.width, newImage.height +60);
    image(newImage, 0, 0);
  }

  //checks if the mouse is pressed over the "vertical seam" 
  //photo button. If it is, shows the original image with a 
  //vertical seam.
  if (mousePressed == true && mouseX>3*(newImage.width/5) &&
    mouseX< 4*(newImage.width/5) && mouseY> newImage.height) {
    long[][] energyTable = getEnergyTable(orig);
    long[][] smallestEnergySums = shortestPaths(energyTable);
    int[] verticalSeam = getVerticalSeam(smallestEnergySums);
    newImage = drawVerticalSeamImage(orig, verticalSeam);
    frame.setSize(newImage.width, newImage.height +60);
    image(newImage, 0, 0);
  }

  //checks if the mouse is pressed over the "seam cropped photo"
  //button. If it is, shows the seam cropped image.
  if (mousePressed == true && mouseX> 4*(newImage.width/5) &&
    mouseX< 5*(newImage.width/5) && mouseY > newImage.height) {
    int amtSeamsToRemove = 75;
    for (int i = 0; i< amtSeamsToRemove; i++) {
      long[][] energyTable = getEnergyTable(newImage);
      long[][] smallestEnergySums = shortestPaths(energyTable);
      int[] verticalSeam = getVerticalSeam(smallestEnergySums);
      newImage = removeVerticalSeamImage(newImage, verticalSeam);
    }
    //frame.setSize(newImage.width, newImage.height + 60);
    image(newImage, 0, 0);
  }
}

//Draws the buttons for the image choices
void drawButtons(PImage newImage) {
  stroke(0);
  fill(200);
  rect(0, newImage.height, newImage.width/5, 30, 7);
  textSize(10);
  fill(0);
  text("Original Photo", 10, newImage.height, newImage.width/5, 30);
  fill(200);
  rect(newImage.width/5, newImage.height, newImage.width/5, 30, 7);
  textSize(10);
  fill(0);
  text("Energy Photo", newImage.width/5 + 4, newImage.height, newImage.width/5, 30);
  fill(200);
  rect(2*(newImage.width/5), newImage.height, newImage.width/5, 30, 7);
  textSize(10);
  fill(0);
  text("Energy Sum Photo", 2*(newImage.width/5) + 2, newImage.height, newImage.width/5, 30);
  fill(200);
  rect(3*(newImage.width/5), newImage.height, newImage.width/5, 30, 7);
  textSize(10);
  fill(0);
  text("Vertical Seam", 3*(newImage.width/5) + 10, newImage.height, newImage.width/5, 30);
  fill(200);
  rect(4*(newImage.width/5), newImage.height, newImage.width/5, 30, 7);
  textSize(10);
  fill(0);
  text("Seam Cropped", 4*(newImage.width/5) + 10, newImage.height, newImage.width/5, 30);
}

//Removes a vertical seam from an image and returns the
//new image that is one column shorter (one pixel shorter in 
//width).
PImage removeVerticalSeamImage(PImage source, int[] verticalSeam) {
  PImage destination = createImage(source.width-1, source.height, RGB);
  destination.loadPixels();

  int index = 0;
  for (int i = 0; i<source.height; i++) {
    for (int j = 0; j<source.width; j++) {
      if (verticalSeam[i] != j) {
        destination.pixels[index] = source.pixels[(i*source.width) + j];
        index++;
      }
    }
  }
  destination.updatePixels();
  return destination;
}

//Draws the path of the vertical seam in the original image.
//Returns a new image with this vertical seam marked.
PImage drawVerticalSeamImage(PImage source, int[] verticalSeam) {
  PImage destination = createImage(source.width, source.height, RGB);
  destination.loadPixels();

  for (int i = 0; i<source.height; i++) {
    for (int j = 0; j<source.width; j++) {
      if (verticalSeam[i] == j) {
        destination.pixels[(i*source.width)+j] = color(255, 0, 0);
      } else {
        destination.pixels[(i*source.width)+j] = source.pixels[(i*source.width)+j];
      }
    }
  }
  destination.updatePixels();
  return destination;
}

//Using dynamic programming to find the
//smallest cost energies/smallest path of energy
//of connected pixels. Starts from the top
//and works downwards, adding the cost of the cheapest above 
//neighbor to each pixel. This is useful
//in finding the least cost vertical seam that
//needs to be removed. Stores this in a 2d array of
//type long.
long[][] shortestPaths(long[][] energyTable) {
  long[][] smallestPathSum = energyTable;
  for (int i = 1; i< energyTable.length; i++) {
    for (int j = 0; j< energyTable[i].length; j++) {

      if (j % energyTable[i].length == 0) {
        if (energyTable[i-1][j] < energyTable[i-1][j+1]) {
          smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j];
        }
        smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j+1];
      } else 
        if (j % energyTable[i].length == energyTable[i].length-1) {
        if (energyTable[i-1][j] < energyTable[i-1][j-1]) {
          smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j];
        }
        smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j-1];
      } else {
        if (energyTable[i-1][j] < energyTable[i-1][j-1] &&
          energyTable[i-1][j] < energyTable[i-1][j+1]) {
          smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j];
        } else 
          if (energyTable[i-1][j-1] < energyTable[i-1][j] &&
          energyTable[i-1][j-1] < energyTable[i-1][j+1]) {
          smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j-1];
        } else {
          smallestPathSum[i][j] = energyTable[i][j] + energyTable[i-1][j+1];
        }
      }
    }
  }
  return smallestPathSum;
}

//Goes through the last row of the smallestEnergySums and finds 
//smallest sum. The index of this smallest sum is the starting 
//index for the vertical seam, going from the bottom to the top.
//Then it goes through each row, and in each row checks the 
//three adjacent pixels above the row and finds the pixel with
//the smallest energy sum. the index of that pixel is then stored 
//inside the vertical seam array.
//the method returns an array of the column/x indexes that need
//to be removed.
int[] getVerticalSeam(long[][] smallestEnergySums) {
  long smallestSoFar = Integer.MAX_VALUE;
  int smallestSoFarIndex = 0;
  int lastRow = smallestEnergySums.length-1;
  int[] verticalSeam = new int[smallestEnergySums.length];
  for (int j = 0; j< smallestEnergySums[lastRow].length; j++) {
    if (smallestEnergySums[lastRow][j] < smallestSoFar) {
      smallestSoFar = smallestEnergySums[lastRow][j];
      smallestSoFarIndex = j;
      verticalSeam[lastRow] = j;
    }
  }

  for (int i = lastRow; i>0; i--) {
    if (smallestSoFarIndex == 0) {
      long topMiddle = smallestEnergySums[i-1][smallestSoFarIndex];
      long topRight = smallestEnergySums[i-1][smallestSoFarIndex+1];

      if (topRight < topMiddle) {
        smallestSoFarIndex = smallestSoFarIndex+1;
        verticalSeam[i-1] = smallestSoFarIndex;
      } else {
        verticalSeam[i-1] = smallestSoFarIndex;
      }
    } else if (smallestSoFarIndex == smallestEnergySums[0].length-1) {
      long topLeft = smallestEnergySums[i-1][smallestSoFarIndex-1];
      long topMiddle = smallestEnergySums[i-1][smallestSoFarIndex];

      if (topLeft < topMiddle) {
        smallestSoFarIndex = smallestSoFarIndex-1;
        verticalSeam[i-1] = smallestSoFarIndex;
      } else {
        verticalSeam[i-1] = smallestSoFarIndex;
      }
    } else {
      long topLeft = smallestEnergySums[i-1][smallestSoFarIndex-1];
      long topMiddle = smallestEnergySums[i-1][smallestSoFarIndex];
      long topRight = smallestEnergySums[i-1][smallestSoFarIndex+1];
      if (topLeft < topMiddle && topLeft< topRight) {
        smallestSoFarIndex = smallestSoFarIndex-1;
        verticalSeam[i-1] = smallestSoFarIndex;
      } else if (topMiddle<topLeft && topMiddle<topRight) {
        verticalSeam[i-1] = smallestSoFarIndex;
      } else {
        smallestSoFarIndex = smallestSoFarIndex+1;
        verticalSeam[i-1] = smallestSoFarIndex;
      }
    }
  }

  return verticalSeam;
}

//Creates an image of the energy
//sums. The image is lighter at the bottom pixels
//because the energies get added together as you go
//down the image
PImage drawEnergySumsImage(PImage source, long[][] energySums, long min, long max) {
  PImage destination = createImage(source.width, source.height, RGB);
  destination.loadPixels();

  for (int i = 0; i<source.height; i++) {
    for (int j = 0; j<source.width; j++) {
      long energySum = energySums[i][j];
      float greyscaleValue = map(energySum, min, max, 0, 255);
      destination.pixels[(i*source.width) + j] = color(greyscaleValue);
    }
  }
  destination.updatePixels();
  return destination;
}

//Creates a PImage to show the energy of the original 
//picture. Maps the energy to values between 0 and 255.
PImage drawEnergyPicture(PImage source, long[][] energyTable, long min, long max) {
  PImage energyPic = createImage(source.width, source.height, RGB);

  energyPic.loadPixels();

  for (int i = 0; i<source.height; i++) {
    for (int j = 0; j<source.width; j++) {
      long energy = energyTable[i][j];
      float greyscaleValue = map(energy, min, max, 0, 255);
      energyPic.pixels[(i*source.width) + j] = color(greyscaleValue);
    }
  }
  energyPic.updatePixels();
  return energyPic;
}

//goes through the values in a 2d array
//and finds the largest value.
long findMax(long[][] values) {
  long maxSoFar = Integer.MIN_VALUE;
  for (int i = 0; i< values.length; i++) {
    for (int j = 0; j<values[i].length; j++) {
      if (values[i][j] > maxSoFar) {
        maxSoFar = values[i][j];
      }
    }
  }
  return maxSoFar;
}

//goes through the values in the energyTable
//and finds the smallest energy value
long findMin(long[][] values) {
  long minSoFar = Integer.MAX_VALUE;
  for (int i = 0; i< values.length; i++) {
    for (int j = 0; j<values[i].length; j++) {
      if (values[i][j]< minSoFar) {
        minSoFar = values[i][j];
      }
    }
  }
  return minSoFar;
}

//Creates a 2-d array with the energy values
//for each corresponding pixel in the image.
long[][] getEnergyTable(PImage source) {
  long[][] energyTable = new long[source.height][source.width];

  for (int row = 0; row < source.height; row++) {
    for (int column = 0; column<source.width; column++) {

      //variables that hold the x and
      //y position of the current pixel
      int pixelOfInterestX = column;
      int pixelOfInterestY = row;

      //Finds the location of the pixel to the left
      //of the original pixel we are looking at: (x-1,y).
      int leftPixelLocation = (pixelOfInterestY*source.width) + 
        (((pixelOfInterestX-1)+source.width)%source.width);

      //Finds the location of the pixel to the right
      //of the original pixel we are looking at: (x+1,y).
      int rightPixelLocation = (pixelOfInterestY*source.width) +
        (((pixelOfInterestX+1)+source.width)%source.width);

      //Finds the location of the pixel above 
      //the original pixel we are looking at: (x,y-1).
      int topPixelLocation = ((((pixelOfInterestY-1)+source.height)
        %source.height)*source.width) + pixelOfInterestX; 

      //Finds the location of the pixel below
      //the original pixel we are looking at: (x,y+1).
      int bottomPixelLocation = ((((pixelOfInterestY+1)+source.height)
        %source.height)*source.width) + pixelOfInterestX;

      //finds the absolute value in differences 
      //of red, green, and blue components between 
      //pixel (x + 1, y) and pixel (x − 1, y).                     
      int diffRedX, diffGreenX, diffBlueX;
      diffRedX = (int)abs(red(source.pixels[rightPixelLocation]) -
        red(source.pixels[leftPixelLocation]));
      diffGreenX = (int)abs(green(source.pixels[rightPixelLocation]) -
        green(source.pixels[leftPixelLocation]));
      diffBlueX = (int)abs(blue(source.pixels[rightPixelLocation]) -
        blue(source.pixels[leftPixelLocation]));

      //squares the differences and adds the values together
      //to get the change in x squared value.
      int deltaXsquared = (int)(sq(diffRedX) + sq(diffGreenX) + sq(diffBlueX));

      //Finds the absolute value in differences 
      //of red, green, and blue components between pixel 
      //(x, y+1) and pixel (x, y-1). 
      int diffRedY, diffGreenY, diffBlueY;
      diffRedY = (int)abs(red(source.pixels[bottomPixelLocation]) -
        red(source.pixels[topPixelLocation]));
      diffGreenY = (int)abs(green(source.pixels[bottomPixelLocation]) -
        green(source.pixels[topPixelLocation]));
      diffBlueY = (int)abs(blue(source.pixels[bottomPixelLocation]) -
        blue(source.pixels[topPixelLocation]));

      int deltaYsquared = (int)(sq(diffRedY) + sq(diffGreenY) + sq(diffBlueY));

      //adds the change in x squared value with
      //the change in y squared value to get the energy 
      //of the pixel at location row, column.
      long energy = deltaXsquared + deltaYsquared;
      //assigns the energy to the position
      //row and column in the energy table.
      energyTable[row][column] = energy;
    }
  }
  return energyTable;
}

