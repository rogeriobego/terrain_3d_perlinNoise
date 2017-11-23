/*
 3D Terrain Generation with Perlin Noise in Processing
 rogerio.bego@hotmail.com - 21/Nov/2017
 based on Daniel Shiffman's tutorial - https://youtu.be/IKB1hWWedMk
 
 obs: you have to add PeasyCam library
*/

import peasy.*;
PeasyCam cam; 
int cols, rows, s;
int w,h;
float t=0, vt=0.01;                // t and speed of t
float xoffInit=0, vXoffInit=0.01;  // xoffInit and speed of xoffInit
float inc=0.025;                   // increment of noise()
boolean showGrid=false;
boolean showMessage=false;      // show message depending on position 
float xMessage, yMessage, zMessage;
color greenLight=color(50,150,50);
color greenDark=color(10,50,10);
color white=color(255);
color cyan=color(0,90,90);
color blue=color(0,0,70);

void setup(){
   size(600,600,P3D);
   s=5;
   w=800;
   h=800;
   cols=w/s;
   rows=h/s;
   cam=new PeasyCam(this,400,400,200,700);
}

void draw(){
  lights();
  background(blue);
  
  pushMatrix();
  translate(0,height*0.3,-100);
  rotateX(PI/3);

  if (showGrid){
    stroke(100); noFill();
  } else {
    noStroke();
  }
  
  xoffInit+=vXoffInit;
  float yoff=t;
  
  //show a message at location  t=0 and xOffInit=0
  if (t>=-rows*inc && t<=0 && xoffInit>=-cols*inc && xoffInit<=0){
    //rows*inc and cols*inc is 4 now
    showMessage=true;
  } else {
    showMessage=false;
  }
  
  for (int y=0;y<rows;y++){
     beginShape(TRIANGLE_STRIP);
     float xoff=xoffInit;
     
     for (int x=0;x<cols;x++){
       
       // computes the height (z and z2)
       float z=map(noise(xoff,yoff),0,1,-100,100);
       yoff+=inc;
       float z2=map(noise(xoff,yoff),0,1,-100,100);
       yoff-=inc;
       
       // define fill color based on z value
       if (showGrid==false){
          // change Hue value of greenDark and greenLight (0 until same color) 
          // based on noise() using xoff and yoff
          colorMode(HSB);
          float n=noise(xoff+1,yoff+1);
          float hueGD=map(n,0,1,0,hue(greenDark)*2);
          float hueGL=map(n,0,1,0,hue(greenLight)*2);
          color gd=color(constrain(hueGD,0,hue(greenDark)),saturation(greenDark),brightness(greenDark));
          color gl=color(constrain(hueGL,0,hue(greenDark)),saturation(greenLight),brightness(greenLight));
          colorMode(RGB);
   
          if (z>25){                  // snow (color from white to greenLight)
            fill(lerpColor(gl,white,map(z,25,40,0,1)));
          } else if (z>-25){          // forest (greenLight to greenDark)
            fill(lerpColor(gd,gl,map(z,-25,25,0,1)));
          } else if (z>-40){         // forest (green dark)
            fill(gd);
          }else {                    // lake (cyan) flat (force z=-40)
            z=-40;
            z2=-40;
            fill(cyan);
          }
        }

        vertex(x*s,y*s,z);
        vertex(x*s,(y+1)*s,z2);
        xoff+=inc;
        
        if (showMessage){
           if (int(xoff*100.0)==0 && int(yoff*100.0)==0){
             xMessage=x*s;
             yMessage=y*s;
             zMessage=100;
           }
        }
     }
     yoff+=inc;
     endShape();
  }
  t-=vt;

  // show Message
  if (showMessage){
     fill(255,0,0);
     pushMatrix();
     translate(xMessage,yMessage,zMessage);
     stroke(255,0,0);
     line(0,0,0,0,0,-200);
     rotateX(-PI/4);
     textSize(20);
     text("rogerio.bego@hotmail.com",0,0);
     popMatrix();
  }

  popMatrix();
  
  // information
  fill(255,0,0);
  textSize(30);
  text("t="+nf(t,1,2),10,30);
  text("xoffInit="+nf(xoffInit,1,2),10,60);
  text("press arrow keys or space",width*0.6,30);
  text("or pgUp / pgDown",width*0.6,60);
  text("or drag mouse buttons",width*0.6,90);
  
}

void keyPressed(){
  if (key==CODED){
    if (keyCode==UP){ 
       vt+=0.01; 
    } else if (keyCode==DOWN){ 
       vt-=0.01;
    } else if (keyCode==LEFT){
       vXoffInit-=0.01; 
    } else if (keyCode==RIGHT){
       vXoffInit+=0.01;
    }
  }  else  if (keyCode==16){ // pgup  
       inc+=0.001; 
  } else if (keyCode==11){ // pgdown   
       inc-=0.001;
  }  else if (key==' '){    // space bar  showGrid ON/OFF
     showGrid=!showGrid; 
  }
}
