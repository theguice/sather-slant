/* Sather Slant */

import processing.serial.*;
String portname = "/dev/tty.usbserial-AD01TF9Z"; // or "COM5"
Serial port;

import processing.video.*;
import blobDetection.*;

Capture cam;
BlobDetection theBlobDetection;
PImage img;
boolean newFrame=false;

int numLeft = 0;
int numRight = 0;
int total = 0;
int currentCount = 0;
int lastNumBlobs = 0;
float[] lastBX = new float[40];
int skip = 0;

// Position of left hand side of floor
PVector baseLeft;
// Position of right hand side of floor
PVector baseRight;
// Length of floor
float baseLength;

sprite walker;
PImage spriteSheet;


// ==================================================
// setup()
// ==================================================
void setup()
{
  // Size of applet
  size(640, 480);
  // Capture
  cam = new Capture(this, 40*4, 30*4, 15);
        // Comment the following line if you use Processing 1.5
        cam.start();
        
  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
  img = new PImage(80,60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(0.3f); // will detect bright areas whose luminosity > 0.2f;
  
  textFont(createFont("Georgia", 36));
  
  port = new Serial(this, portname, 9600);
  
  baseLeft = new PVector(0,height-100);
  baseRight = new PVector(width, height-100);
  
  smooth();
  spriteSheet = loadImage("sprSht1.png");
  walker = new sprite();
}

// ==================================================
// captureEvent()
// ==================================================
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}

// ==================================================
// draw()
// ==================================================
void draw()
{
  if (skip > 0) {
    skip--;
  }

  if (newFrame)
  {
    newFrame=false;
    image(cam,0,0,width,height);
    img.copy(cam, 0, 0, cam.width, cam.height, 
        0, 0, img.width, img.height);
    fastblur(img, 2);
    theBlobDetection.computeBlobs(img.pixels);
    drawBlobsAndEdges(true,true);
  }
  int diff = numLeft - numRight;
  baseLeft = new PVector(0,height-100-(diff*10));
  baseRight = new PVector(width, height-100+(diff*10));
  // draw base
  
  if (skip > 0) {
    fill(255);
  } else {
    fill(200); 
  }
  quad(baseLeft.x, baseLeft.y, baseRight.x, baseRight.y, baseRight.x, height, 0, height);

  
  textSize(30);
  fill(0);
  text(str(numLeft), 10, height-40, 540, 300);
  text(str(numRight), width-40, height-40, 540, 300);
  /*
  fill(255);
  text(str(currentCount), 300, 300, 540, 300);
  fill(0);
  text(str(currentCount), 300, 380, 540, 300);
  */

  
  //delay(20);
  
  if ((numRight + numLeft) > total) {
    if (total - (numRight * 2) < 0) {
      port.write(1);
      walker.turn(2);
    } else if (total - (numLeft * 2) < 0) {
      port.write(2);
      walker.turn(3);
    } else {
      port.write(3);
    }
    total = numRight + numLeft;  
  }
  if (skip > 0) {
    walker.check();
  }
}

// ==================================================
// drawBlobsAndEdges()
// ==================================================
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA,eB;
  
  int i=0;
  int numBlobs = theBlobDetection.getBlobNb();
  float direction = 0;
  float blobSize = 0;
  
  for (int n=0 ; n<numBlobs ; n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      
      // if same # blobs since last iteration 
      if (numBlobs == lastNumBlobs) {
        // record movement of blob center to determine direction
        blobSize = (b.w*100) * (b.h*100);
        if (blobSize > 2000) {
          direction += b.x - lastBX[n];
          i++;    
        }
      }
      lastBX[n] = b.x;
      
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0,255,0);
        for (int m=0;m<b.getEdgeNb();m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        strokeWeight(1);
        stroke(255,0,0);
        rect(
          b.xMin*width,b.yMin*height,
          b.w*width,b.h*height
          );
      }

    }

  }
  
  // if i can track how long a particular blob stays alive...
  
  // if above a blob threshold   (threshold determined by noisiness of environment)
  if (skip == 0) {  
    if (direction > 0.2 || direction < -0.2) {
      println("Direction: " + str(direction));
      
      if (direction < 0) {
        numRight++;
        skip = 240;
      } else if (direction > 0) {
        numLeft++;
        skip = 240; 
      }
    }
  }
  lastNumBlobs = numBlobs;
  currentCount = i;
  
  
}

// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img,int radius)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}

class sprite {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;
  
  sprite() {
    cell = new PImage[12];
    for (int y = 0; y < 4; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet.get(x*24,y*48, 24,48);
  }
  
  void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
    //println (dir);
  }
  
  void check() {
    if (cnt++ > 7) {
      cnt = 0;
      step++;
      if (step >= 4) 
        step = 0;
    }
    int idx = dir*3 + (step == 3 ? 1 : step);
    image(cell[idx], width/2, height-80);
  }
}


