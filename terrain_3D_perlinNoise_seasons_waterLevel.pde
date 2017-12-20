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
//enum Seasons {spring, summer, autumn, winter}
//Seasons season=Seasons.spring;
int spring=0;
int summer=1;
int autumn=2;
int winter=3;
String[] seasonName={"spring","summer","autumn","winter"};
float waterLevel=-40;
int snow=0;
int forestStart=1;
int forestEnd=2;
int lake=3;
int season=spring;
int seasonNext=summer;
boolean seasonAuto=true;
color[][] seasons;
color[] now; 
float time=0;
float dTime=0.001;
float zSnow=0;

void setup(){
   size(1000,500,P3D);
   s=5;
   w=1000;
   h=800;
   cols=w/s;
   rows=h/s;
   cam=new PeasyCam(this,400,400,200,700);
   seasons=new color[4][4];
   seasons[spring][snow]=color(255);         // snow top mountain
   seasons[spring][forestStart]=color(0,254,52);    // start forest
   seasons[spring][forestEnd]=color(52,152,2);    // finish forest
   seasons[spring][lake]=color(102,254,255);  // lake
   seasons[summer][snow]=color(255);         // snow top mountain
   seasons[summer][forestStart]=color(52,152,0);    // start forest
   seasons[summer][forestEnd]=color(0,50,0);    // finish forest
   seasons[summer][lake]=color(20,150,200);  // lake
   seasons[autumn][snow]=color(255);         // snow top mountain
   seasons[autumn][forestStart]=color(255,204,0);    // start forest
   seasons[autumn][forestEnd]=color(154,255,0);    // finish forest
   seasons[autumn][lake]=color(0,204,203);  // lake
   seasons[winter][snow]=color(255);         // snow top mountain
   seasons[winter][forestStart]=color(102,254,255);    // start forest
   seasons[winter][forestEnd]=color(0,187,214);    // finish forest
   seasons[winter][lake]=color(60,150,150);  // lake
   now=new color[4];
   now[snow]=seasons[season][snow];
   now[forestStart]=seasons[season][forestStart];
   now[forestEnd]=seasons[season][forestEnd];
   now[lake]=seasons[season][lake];
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

  if (showGrid==false){
     // increase the time of seasons
     if (seasonAuto){
       time+=dTime;
       if (time>1) {
         time=0;
         season+=1;
         if (season>3) {
           season=0;
           seasonNext=1;
         } else {
           seasonNext=season+1;
           if (seasonNext>3) seasonNext=0;
         }
       }
     }
     now[snow]=lerpColor(seasons[season][snow],seasons[seasonNext][snow],time);
     now[forestStart]=lerpColor(seasons[season][forestStart],seasons[seasonNext][forestStart],time);
     now[forestEnd]=lerpColor(seasons[season][forestEnd],seasons[seasonNext][forestEnd],time);
     now[lake]=lerpColor(seasons[season][lake],seasons[seasonNext][lake],time);
     
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
          float hueFS=map(n,0,1,0,hue(now[forestStart])*2);
          color FS=color(constrain(hueFS,0,hue(now[forestStart])),saturation(now[forestStart]),brightness(now[forestStart]));
          float hueFE=map(n,0,1,0,hue(now[forestEnd])*2);
          color FE=color(constrain(hueFE,0,hue(now[forestEnd])),saturation(now[forestEnd]),brightness(now[forestEnd]));
          colorMode(RGB);
          
          
           // calc z for snow following season
          float theta=sin(((float)season+time)*HALF_PI);
          
          zSnow=map(theta,-1,1,0,40);
          
          waterLevel=-35.0+10.0*sin(theta);
          
          if (z>zSnow){                  // snow (color from white to greenLight)
            // fill(now[snow]);
            fill(lerpColor(FS,now[snow],map(z,zSnow,50,0,1)));
          } else if (z>-25){          // forest (greenLight to greenDark)
            //fill(now[forestStart]);
            //fill(lerpColor(now[forestEnd],now[forestStart],map(z,-25,zSnow,0,1)));
            fill(lerpColor(FE,FS,map(z,-25,zSnow,0,1)));
          } else if (z>waterLevel){         // forest (green dark)
            //fill(now[forestEnd]);
            fill(FE);
          }else {                    // lake (cyan) flat (force z=-40)
            
            z=waterLevel;
            z2=waterLevel;
            fill(now[lake]);
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
  float v=season+time;
  //if (v>3.5) v=0;
  String tex="season";
  if (seasonAuto){
    tex+=" (auto)";
  }
  text(tex+" = "+seasonName[constrain(round(v),0,3)]+" -  "+nf(v,1,2),10,90);
  text("waterLevel="+nf(waterLevel,1,2),10,120);
  //help
  text("flight direction:  arrow keys",width*0.6,0);
  text("camera:   drag mouse buttons",width*0.6,30);
  text("inc/dec details:   pgUp / pgDown",width*0.6,60);
  text("season:    s key",width*0.6,90);
  text("grid:     space bar",width*0.6,120);
  
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
  } else if (key=='s' || key=='S'){
     if (seasonAuto){
        seasonAuto=false;
     } else {
        season+=1;
        if (season>3){
          season=0;
          seasonAuto=true;
        }
     }
     time=0;
     
  }
}