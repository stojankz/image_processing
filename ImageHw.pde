//Klementina Stojanovska
//CSE 270M

void setup() {
  int start = millis();
  PImage orig = loadImage("flowers.jpg");

  // I set my pictures up in a grid. The far-most left picture
  //in each row is the original picture. In the first row, I show
  //the effects of the soften method using different strengths
  // and in the second row, I show effects of 
  //the soften2 method using different strengths. The third row
  //has the sharpen method and the 2 filters.
  size(4*orig.width, 3*orig.height);

  PImage soften1 = soften(orig,3); 
  PImage soften2 = soften(orig,5);
  PImage soften3 = soften(orig, 9);
  PImage softenTwo1 = soften2(orig,3);
  PImage softenTwo2 = soften2(orig, 5);
  PImage softenTwo3 = soften2(orig, 9);
  PImage sharpen = sharpen(orig);
  PImage filter1 = colorize(orig);
  PImage filter2 = colorEmboss(orig);
  

  image(orig, 0, 0);
  image(soften1, orig.width, 0);
  image(soften2, 2*orig.width, 0);
  image(soften3, 3*orig.width, 0);
  image(orig, 0, orig.height);
  image(softenTwo1, orig.width, orig.height);
  image(softenTwo2, 2*orig.width, orig.height);
  image(softenTwo3, 3*orig.width, orig.height);
  image(orig, 0, 2*orig.height);
  image(sharpen, orig.width, 2*orig.height);
  image(filter1, 2*orig.width, 2*orig.height);
  image(filter2, 3*orig.width, 2*orig.height);

  //gets the total time it took for my program to run
  //and prints it.
  int end = millis();
  int time = end - start;
  print(time);
}

PImage applyFilter(PImage source, int[][] matrix) {
  PImage destination = createImage(source.width, source.height, RGB);
  int offset = matrix.length/2;
  int iPixelOfInterestX, iPixelOfInterestY;
  int dX;
  int pixelLocation;

  for (int iRow = 0; iRow< source.height; iRow++) {
    for (int iColumn = 0; iColumn< source.width; iColumn++) {
      float sumR = 0;
      float sumG = 0;
      float sumB = 0;
      int weightsAdded = 0;
      int dY = -offset;

      for (int mRow = 0; mRow< matrix.length; mRow++) {
        //dX keeps the delta to find the pixel you are 
        //looking for. This sets dX to the negative of the
        //largest offset which is the matrix length
        //divided by 2. 
        //For example, a matrix that is 5x5, the center is (2,2).
        //This sets the dX to -2, which when added to the column,
        //gives you the pixel you are looking for.
        dX = -offset;

        for (int mColumn = 0; mColumn< matrix.length; mColumn++) {
          //Uses dX and dY to find the corresponding pixel
          //in the picture
          iPixelOfInterestX = iColumn + dX;
          iPixelOfInterestY = iRow + dY;

          //Checks whether the pixelOfInterest is out of
          //bounds. ie if the row is too small or too big or
          //if the column is too small or too big and sets
          //it to the corresponding row or column.
          if (iPixelOfInterestX < 0) 
            iPixelOfInterestX = 0;
          if (iPixelOfInterestX >= source.width)
            iPixelOfInterestX = source.width-1;
          if (iPixelOfInterestY < 0)
            iPixelOfInterestY = 0;
          if (iPixelOfInterestY >= source.height)
            iPixelOfInterestY = source.height-1;

          //Finds the location of the pixel you are looking for in the
          //original image.
          pixelLocation = (iPixelOfInterestY*source.width) + iPixelOfInterestX;
          //Gets the color in that pixel
          color c = source.pixels[pixelLocation];

          //EFFICIENCY: I changed the variables from being
          //floats like below to ints. int's take up less
          //memory so the code became more efficient 
          int cRed = (int)(red(c));
          int cGreen = (int)(green(c));
          int cBlue = (int)(blue(c));

          //float cRed = red(c);
          //float cGreen = green(c);
          //float cBlue = blue(c);

          sumR = sumR + 
            (matrix[mRow][mColumn]*cRed);
          sumG = sumG + 
            (matrix[mRow][mColumn]* cGreen);
          sumB = sumB +
            (matrix[mRow][mColumn]* cBlue);

          weightsAdded = weightsAdded + matrix[mRow][mColumn];
          dX++;
        }
        dY++;
      }
      //Calculates the new red, green, and blue components
      //of the pixel   
      int newR = (int)constrain(sumR/weightsAdded,0,255);
      int newG = (int)constrain(sumG/weightsAdded,0,255);
      int newB = (int)constrain(sumB/weightsAdded,0,255);
      //Sets the original pixel to the new filtered colors
      //EFFICIENCY: Instead of calling color() I used bit shifting
      destination.pixels[(iRow*source.width)+iColumn] = newR<<16 |
                                                        newG << 8 |
                                                        newB;
    }
  }
  destination.updatePixels();
  return destination;
}

//This method softens the image by a certain strength.
//It creates a 2d array matrix a size of strength x strength
//and sets each of the values in the matrix as 1.
//It then returns a PImage that uses that matrix in the applyFilter
//method.
PImage soften(PImage source, int strength) {
  int[][] matrix = new int[strength][strength];
  for (int i = 0; i< matrix.length; i++) {
    for (int j = 0; j<matrix.length; j++) {
      matrix[i][j] = 1;
    }
  }

  PImage softenedImage = applyFilter(source, matrix);
  return softenedImage;
}

//Creates a matrix to sharpen the image, then uses that
//matrix in applyFilter to create a new PImage. Returns that
//new PImage
PImage sharpen(PImage source) {
  int[][] matrix = {{ -1, -1, -1}, 
                    { -1, 9, -1}, 
                    { -1, -1, -1}};

  //EFFICIENCY: I changed the matrix from
  //using a loop like below to just writing the 
  //values in the matrix.
  //  int[][] matrix = new int[3][3];
  //  for(int i = 0; i< matrix.length; i++){
  //    for(int j = 0; j<matrix.length; j++){
  //     matrix[i][i] = -1;
  //    }
  //  }
  //  matrix[1][1] = 9;

  PImage sharpenedImage = applyFilter(source, matrix);
  return sharpenedImage;
}

//soften2 is another soften method that sets all
//of the values of the matrix array to 1 except the
//corner elements in the matrix. This is to make the 
//matrix act more like a circle
PImage soften2(PImage source, int strength) {
  int[][] matrix = new int[strength][strength];
  for (int i = 0; i<matrix.length; i++) {
    for (int j = 0; j< matrix.length; j++) {
      if ( i == 0 && j == 0 || i == matrix.length-1 && j==0 || 
        i == 0 && j == matrix.length-1 || i == matrix.length-1 &&
        j == matrix.length-1) {
        matrix[i][j] = 0;
      } else {
        matrix[i][j] = 1;
      }
    }
  }

  PImage softened2 = applyFilter(source, matrix);
  return softened2;
}

//This is a filter I created using a certain matrix in
//applyFilter
PImage colorize(PImage source) {
  int[][] matrix = { { 14, -9, -2}, 
                     { 0, -10, 14}, 
                     { -1, 0, -6}};

  PImage filtered = applyFilter(source, matrix);
  return filtered;
}

//This is another filter I created using
//applyFilter
PImage colorEmboss(PImage source){
  int[][] matrix = { {-3, -1, 7},
                     {-12, -9, 7},
                     {12, 5, -7} };
  PImage filtered = applyFilter(source, matrix);
  return filtered;
}
