import processing.video.*;
import  java.util.*;

Movie video; //video to analyze
HashMap<Integer, ColorCounter> colorMap; //map to look up all tracked colors
ArrayList<ColorCounter> colorList; //sorted list of colors that are shown in the pie chart


void setup() {
  size(1200, 700);
  frameRate(15);
  selectInput("Select a video file:", "fileSelected");
  colorMap = new HashMap();
  colorList = new ArrayList();

  textSize(7);
}

void fileSelected(File file) {
  video = new Movie(this, file.getAbsolutePath());
  video.play();
  video.volume(0);
  colorMap = new HashMap();
  colorList = new ArrayList();
}



// Called every time a new frame is available to read
void movieEvent(Movie video) {
  video.read();
  video.filter(POSTERIZE, 10); //use filter to group similar colors together


  //reset color occurrences for this frame
  for (int i=colorList.size()-1; i>=0; i--) {
    ColorCounter f = colorList.get(i);
    f.count=0;
  }

  //analyze all pixels in this video frame
  int totalPixelCount = video.pixels.length;
  for (int i=0; i<totalPixelCount; i++) {
    int pixel = video.pixels[i];
    ColorCounter f = colorMap.get(pixel);
    if (f!=null) {
      f.count++;
    } else {
      colorMap.put(pixel, new ColorCounter(pixel));
    }
  }

  //calculate the ratio of color occurrences/pixels in a frame
  for (int i=colorList.size()-1; i>=0; i--) {
    ColorCounter f = colorList.get(i);
    double ratio = (double) f.count/totalPixelCount;
    f.factor+=ratio;
  }

  //create color list from map
  colorList = new ArrayList<ColorCounter>(colorMap.values());

  //sort color list by color occurrences
  Collections.sort(colorList, new CountComparator());
}


void draw() {
  background(100);
  pushMatrix();
  translate(width/4*3, height/2);
  pieChart(colorList, 200, 330); //draw pie chart
  popMatrix();

  //if video is loaded, draw current frame
  if (video!=null) {
    pushMatrix();
    translate(width/4, height/2);
    imageMode(CENTER);
    image(video, 0, 0, width/40*16, width/40*9);
    popMatrix();
  }
}