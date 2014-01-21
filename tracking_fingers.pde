// import the fingertracker library
// and the SimpleOpenNI library for Kinect access
import fingertracker.*;
import SimpleOpenNI.*;
PrintWriter output;
import processing.serial.*;
import java.io.*;
int mySwitch=0;
int counter=0;
String [] subtext;
Serial myPort;

// declare FignerTracker and SimpleOpenNI objects
FingerTracker fingers;
SimpleOpenNI kinect;
// set a default threshold distance:
// 625 corresponds to about 2-3 feet from the Kinect
int threshold = 625;
float fx_d = 5.9421434211923247e+02;
float fy_d = 5.9104053696870778e+02;
float cx_d = 3.3930780975300314e+02;
float cy_d = 2.4273913761751615e+02;
float k1_d = -2.6386489753128833e-01;
float k2_d = 9.9966832163729757e-01;
float p1_d = -7.6275862143610667e-04;
float p2_d = 5.0350940090814270e-03;
float k3_d = -1.3053628089976321e+00;
boolean[] how_many_x = new boolean[5000];

void setup() {
  output = createWriter("motor.txt");
   int i; 
  // initialize your SimpleOpenNI object
  // and set it up to access the depth image
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth(640,480,30);
 /* for(i=0;i<5000;i++)
  {
      how_many_x[i] = boolean(0);
  }*/
  // mirror the depth image so that it is more natural
  kinect.setMirror(true);
  size(kinect.depthWidth(),kinect.depthHeight());
  // initialize the FingerTracker object
  // with the height and width of the Kinect
  // depth image
  fingers = new FingerTracker(this, 640, 480);
  // the "melt factor" smooths out the contour
  // making the finger tracking more robust
  // especially at short distances
  // farther away you may want a lower number
  fingers.setMeltFactor(150);
 /* myPort = new Serial(this, "COM2", 9600);
   myPort.bufferUntil('\n');*/
}


void draw() {
  // get new depth data from the kinect
  kinect.update();
  // get a depth image and display it
  PImage depthImage = kinect.depthImage();
  image(depthImage, 0, 0);

  // update the depth threshold beyond which
  // we'll look for fingers
  fingers.setThreshold(threshold);
  
  // access the "depth map" from the Kinect
  // this is an array of ints with the full-resolution
  // depth data (i.e. 500-2047 instead of 0-255)
  // pass that data to our FingerTracker
  int[] depthMap = kinect.depthMap();
  fingers.update(depthMap); 

  // iterate over all the contours found
  // and display each of them with a green line
  stroke(0,255,0);
  for (int k = 0; k < fingers.getNumContours(); k++) {
    fingers.drawContour(k);
  }
  
  // iterate over all the fingers found
  // and draw them as a red circle
  noStroke();
  
  for (int i = 0; i < fingers.getNumFingers(); i++) {
    
    int j,k;
    float pointz;
    PVector position = fingers.getFinger(i);
    
  //  PVector new1 = position;
    fill((255 - (30 * i)),30 * i,0);
    ellipse(position.x - 5, position.y -5, 10, 10);
    depth(position,depthMap);
     output.println("Hellooooooo");
  //kinect.convertProjectiveToRealWorld(position, new1);
  //  pointz = depthMap[int(position.y*640+position.x)];
   // print("Depth: " + pointz + "\n");
   // float z = 1.0 / (depthMap* -0.0030711016 + 3.3309495161);
  /*  for(j=0;j<640;j++)
    {
        for(k=0;k<480;k++)
        {
          print("\t" + depthMap[k*640 + j] + "\n");
        }
    }*/
  //  print("Depth: " + z + "\n");
  //  float x_depth, y_depth;
  //  x_depth = 1.0 / (position.x* -0.0030711016 + 3.3309495161);
  //  y_depth = 1.0 / (position.y* -0.0030711016 + 3.3309495161);
   // print("Finger is:" + i + "position.x:" + (position.x) + " y pos:" + (position.y) + "\n");
  }
  
  // show the threshold on the screen
  fill(255,0,0);
  text(threshold, 10, 20);
}


void depth(PVector x1, int[] depthMap)
{
  int i,j,x; 
  float m,new_x,new_y;
   for(i = (floor(x1.x) - 5); i < (floor(x1.x) + 5) && (i < 640) && (i > 0) ; i++)
   {
       for(j = (floor(x1.y) - 5); j < (floor(x1.y) + 5) && (j < 480) && (j>0); j++)
       {
         if(depthMap[j * 640 + i]  != 0)
         {
             x = depthMap[j * 640 + i];
           //  print( "\n depth of finger is" + (1.0 / (x* -0.0030711016 + 3.3309495161)));
             m = (1.0 / (x* -0.0030711016 + 3.3309495161));
          //   new_x = (x1.x - 320) * (m - 10) * (.0021) * (640/480);
          //   new_y = (x1.y - 240) * (m - 10) * (0.0021)  ;
             x1.x = (x1.x - cx_d) * m / fx_d;
             x1.y = (x1.y - cy_d) * m / fy_d;
             circle(x1);
         //    print("position.x:" + (x1.x)+ " y pos:" + (x1.y) + "\n");
         }
       }
   }
}


// keyPressed event:
// pressing the '-' key lowers the threshold by 10
// pressing the '+/=' key increases it by 10 
void keyPressed(){
  if(key == '-'){
    threshold -= 10;
  }
  
  if(key == '='){
    threshold += 10;
  }
  output.close();
}

void circle(PVector pos)
{
    int pos_x,pos_y,x,y;
    pos_x = abs(int(100 * pos.x));
    pos_y = abs(int(100 * pos.y));
    
                                            
   // print("x: " + pos_x + "\t" + pos_y + " \n");
    for(x=20;x<50;x++)
     {
         for(y=0;y<50;y++)
         {
             if((x^2 + y^2) == 5)
             {
                 if(pos_x == x && pos_y == y)
                 {
                     print("yes");
                 }
             }
         }
     }
 /*    for(x = 0 ; x < 5000; x++)
     {
       print(int(how_many_x[x]));
     }*/
}

void stop()
{
  output.flush();
  output.close();
}
