import java.util.Arrays;
import java.util.Collections;
import android.graphics.Rect;
import java.util.Map;
import java.util.HashMap;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 480; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
final int tw = sizeOfInputArea/12; //Used because fractions confuse me
final int margin = 200;
int buttonMarginBottom = tw / 4;
int buttonMarginHalf = tw / 8;

int scrollLoc = 0;
Rect input = new Rect(
                      margin, 
                      margin, 
                      margin + tw*12, 
                      margin + tw*12
                      );
Rect delete = new Rect(
                       margin, 
                       margin, 
                       margin + tw*6 - buttonMarginHalf, 
                       margin + tw * 2 - buttonMarginBottom
                       );
Rect space = new Rect(
                      margin + tw * 6 + buttonMarginHalf, 
                      margin, 
                      margin + tw * 12, 
                      margin + tw * 2 - buttonMarginBottom
                      );
                      
Rect auto0 = new Rect(margin, margin + tw*8, margin + tw*6, margin + tw*10);
Rect auto1 = new Rect(margin + tw*6, margin + tw*8, margin + tw*12, margin +tw*10);
Rect auto2 = new Rect(margin, margin + tw*10, margin + tw * 6, margin + tw*12);
Rect auto3 = new Rect(margin + tw*6, margin + tw*10, margin + tw*6, margin + tw*12);

Rect[] rects = new Rect[4];
Rect scroll = new Rect(
                        margin, 
                        margin + tw*6, 
                        margin + tw*12, 
                        margin + tw*8
                       );
//char[] alphabet = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
char[] lettersFull = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
int selectedScrollRectIndex = 0;
Rect[] scrollRects = new Rect[23]; // 23 is number of shifts required to go from abcd to wxyz
int letterScrollWidth = scroll.width() / (scrollRects.length + 2); // +2 instead of -1 to allow double width for 'a' and 'z'
char[] letters = {'a', 'b', 'c', 'd'};
String lastTypedLetter = "";
Map<String, char[]> commonLetters = new HashMap<String, char[]>();
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  // can't map char as key, so need to cast when checking previous letter
  commonLetters.put("", new char[] {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put(" ", new char[] {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("a", new char[] {'n', 'r', 't', 'l', 's', 'c', 'm', 'd', 'i', 'b', 'p', 'g', 'u', 'y', 'v', 'k', 'f', 'w', 'h', 'z', 'e', 'x', 'a', 'o', 'j', 'q'});
  commonLetters.put("c", new char[] {'o', 'a', 'h', 'e', 'k', 't', 'i', 'r', 'l', 'u', 'c', 's', 'y', 'd', 'p', 'm', 'n', 'g', 'f', 'b', 'w', 'q', 'v', 'z', 'j', 'x'});
  commonLetters.put("b", new char[] {'a', 'e', 'l', 'o', 'i', 'r', 'u', 's', 'b', 'y', 'c', 't', 'm', 'd', 'h', 'p', 'j', 'n', 'g', 'f', 'w', 'v', 'x', 'k', 'z', 'q'});
  commonLetters.put("e", new char[] {'r', 's', 'n', 'd', 'l', 't', 'a', 'c', 'm', 'e', 'p', 'x', 'i', 'g', 'v', 'y', 'f', 'b', 'w', 'o', 'u', 'h', 'k', 'z', 'q', 'j'});
  commonLetters.put("d", new char[] {'e', 'i', 'a', 'o', 's', 'r', 'u', 'l', 'd', 'y', 'g', 'm', 'b', 'w', 'v', 'c', 'n', 't', 'h', 'f', 'p', 'j', 'k', 'x', 'z', 'q'});
  commonLetters.put("g", new char[] {'e', 'a', 'r', 'i', 'o', 'h', 'u', 'l', 's', 'n', 'g', 'y', 't', 'm', 'b', 'w', 'c', 'd', 'f', 'p', 'v', 'k', 'z', 'x', 'j', 'q'});
  commonLetters.put("f", new char[] {'i', 'o', 'e', 'a', 'r', 'f', 'l', 'u', 't', 's', 'y', 'c', 'm', 'p', 'd', 'n', 'g', 'w', 'b', 'x', 'h', 'k', 'j', 'v', 'z', 'q'});
  commonLetters.put("i", new char[] {'n', 's', 'c', 't', 'o', 'l', 'e', 'a', 'd', 'r', 'm', 'g', 'v', 'p', 'f', 'b', 'z', 'k', 'u', 'x', 'q', 'i', 'h', 'j', 'w', 'y'});
  commonLetters.put("h", new char[] {'e', 'a', 'o', 'i', 'u', 't', 'r', 'y', 'l', 's', 'm', 'n', 'w', 'b', 'p', 'c', 'd', 'f', 'h', 'k', 'g', 'v', 'j', 'x', 'q', 'z'});
  commonLetters.put("k", new char[] {'e', 'i', 'a', 's', 'o', 'l', 'u', 'y', 'r', 'n', 'h', 't', 'm', 'w', 'b', 'k', 'd', 'f', 'p', 'c', 'g', 'v', 'j', 'z', 'q', 'x'});
  commonLetters.put("j", new char[] {'a', 'o', 'e', 'u', 'i', 's', 'c', 'm', 'd', 'p', 'n', 'r', 'k', 'b', 't', 'h', 'f', 'l', 'j', 'v', 'y', 'w', 'g', 'x', 'z', 'q'});
  commonLetters.put("m", new char[] {'a', 'e', 'i', 'o', 'p', 'u', 'b', 'm', 's', 'c', 'y', 'l', 'n', 't', 'r', 'd', 'f', 'w', 'g', 'h', 'v', 'k', 'x', 'j', 'z', 'q'});
  commonLetters.put("l", new char[] {'e', 'i', 'a', 'l', 'o', 'y', 'u', 's', 'd', 't', 'm', 'b', 'v', 'c', 'f', 'k', 'p', 'g', 'w', 'n', 'r', 'h', 'z', 'x', 'j', 'q'});
  commonLetters.put("o", new char[] {'n', 'r', 'l', 'u', 'm', 's', 't', 'o', 'p', 'c', 'd', 'w', 'g', 'v', 'b', 'a', 'i', 'k', 'f', 'e', 'x', 'y', 'h', 'z', 'j', 'q'});
  commonLetters.put("n", new char[] {'g', 'e', 't', 'a', 's', 'd', 'i', 'o', 'c', 'n', 'k', 'u', 'f', 'v', 'y', 'l', 'b', 'h', 'r', 'm', 'z', 'p', 'w', 'j', 'q', 'x'});
  commonLetters.put("q", new char[] {'u', 'i', 'a', 's', 'l', 't', 'r', 'o', 'p', 'e', 'f', 'n', 'b', 'm', 'w', 'q', 'v', 'c', 'd', 'h', 'g', 'x', 'j', 'k', 'y', 'z'});
  commonLetters.put("p", new char[] {'e', 'a', 'r', 'o', 'i', 'l', 'h', 'p', 't', 's', 'u', 'y', 'c', 'm', 'd', 'f', 'n', 'g', 'b', 'w', 'k', 'v', 'x', 'j', 'q', 'z'});
  commonLetters.put("s", new char[] {'t', 'e', 'i', 's', 'h', 'a', 'o', 'c', 'u', 'p', 'm', 'l', 'k', 'y', 'w', 'n', 'b', 'd', 'f', 'v', 'r', 'q', 'g', 'x', 'j', 'z'});
  commonLetters.put("r", new char[] {'e', 'a', 'i', 'o', 's', 't', 'd', 'u', 'm', 'r', 'y', 'n', 'c', 'g', 'l', 'k', 'b', 'p', 'v', 'f', 'h', 'w', 'z', 'j', 'q', 'x'});
  commonLetters.put("u", new char[] {'r', 'n', 's', 'l', 't', 'm', 'e', 'c', 'i', 'b', 'a', 'p', 'd', 'g', 'f', 'k', 'o', 'x', 'v', 'z', 'y', 'h', 'j', 'w', 'u', 'q'});
  commonLetters.put("t", new char[] {'e', 'i', 'a', 'o', 'r', 'h', 's', 't', 'u', 'y', 'l', 'c', 'w', 'm', 'z', 'f', 'b', 'p', 'n', 'd', 'v', 'g', 'k', 'x', 'j', 'q'});
  commonLetters.put("w", new char[] {'a', 'e', 'i', 'o', 'n', 's', 'h', 'r', 'l', 'y', 'b', 'd', 't', 'c', 'm', 'w', 'k', 'p', 'f', 'u', 'g', 'x', 'v', 'j', 'z', 'q'});
  commonLetters.put("v", new char[] {'e', 'i', 'a', 'o', 's', 'r', 'u', 'd', 'c', 'l', 'm', 'y', 'p', 't', 'n', 'b', 'g', 'f', 'v', 'h', 'w', 'x', 'q', 'k', 'z', 'j'});
  commonLetters.put("y", new char[] {'s', 'a', 'n', 'e', 'l', 'p', 'o', 'm', 'c', 't', 'r', 'd', 'i', 'b', 'u', 'w', 'g', 'f', 'h', 'k', 'v', 'z', 'y', 'x', 'j', 'q'});
  commonLetters.put("x", new char[] {'i', 't', 'p', 'e', 'c', 'a', 'o', 'x', 'y', 'u', 's', 'm', 'h', 'f', 'l', 'r', 'b', 'd', 'v', 'w', 'g', 'n', 'k', 'q', 'j', 'z'});
  commonLetters.put("z", new char[] {'e', 'a', 'i', 'o', 'z', 'u', 'y', 'l', 'h', 'm', 'w', 's', 't', 'b', 'd', 'n', 'c', 'r', 'k', 'v', 'f', 'p', 'g', 'j', 'q', 'x'});
  
  int x1, y1, x2, y2;
  for (int i = 0; i < 4; i++) {
    x1 = margin + (tw*3)*i;
    y1 = margin + (tw*2);
    x2 = margin + ((tw*3) * (i+1));
    y2 = margin + tw*6 - buttonMarginBottom;
    // handle margins between letter buttons
    if (i < 3) x2 -= buttonMarginHalf;
    if (i > 0) x1 += buttonMarginHalf;
    rects[i] = new Rect(x1, y1, x2, y2);
  }
    
  for (int i = 0; i < scrollRects.length; i++) {
    if (i == 0) {
      scrollRects[i] = new Rect(
                                margin, 
                                margin + tw*6, 
                                margin + letterScrollWidth*2, 
                                margin + tw*8
                                );
    } else if (i == scrollRects.length -1) {
      // scroll.width() - (int-->float conversion of letterScrollWidth) = 5, which is where that magic number comes from
      scrollRects[i] = new Rect(
                                margin + letterScrollWidth*(i+1), 
                                margin + tw*6, 
                                margin + letterScrollWidth*(i+3)+5, 
                                margin + tw*8
                                );
    } else {
      scrollRects[i] = new Rect(
                                margin + letterScrollWidth*(i+1), 
                                margin + tw*6, 
                                margin + letterScrollWidth*(i+2), 
                                margin + tw*8
                                );
    }    
  }

  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1080, 1920); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
}

void drawRect(Rect r, int hex) {
  fill(hex);
  stroke(0);
  rect((float)r.left, (float)r.top, (float)r.width(), (float)r.height());
}

// I don't feel like changing every instance of drawRect so I'm just making another one
void drawRectNoStroke(Rect r, int val, int index) {
  fill(val);
  //noFill();
  //fill(255);
  noStroke();
  rect((float)r.left, (float)r.top, (float)r.width(), (float)r.height());
  fill(0);
  if (lastTypedLetter == "" || lastTypedLetter == " ")
  {
  // replace to make clearer
  if (lettersFull[index] == 'w') text('z', (float)r.centerX(), (float)r.centerY()+7);
  if (index % 4 == 0) text(lettersFull[index], (float)r.centerX(), (float)r.centerY()+7);
  }
  
  //else
  //{
  // // Just in case someone forgets where x, y and z are (probably not best solution)
  // text('w', (float)r.centerX(), (float)r.top+25);
  // text('-', (float)r.centerX(), (float)r.centerY()+10);
  // text('z', (float)r.centerX(), (float)r.bottom-10);
  //}
  
}

void drawRect(Rect r, int hex, String input) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY()+25); //
}

void drawScroll(Rect r, int hex) {
  drawRect(r, hex);
  // Note: we don't actually need to show this; just for debugging purposes at the moment (although it may be cool to highlight a bar instead of the circle)
  for (int i = 0; i < scrollRects.length; i++) {
    if (i == selectedScrollRectIndex) {
      drawRectNoStroke(scrollRects[i], #FF0000, i);
    } else {
      drawRectNoStroke(scrollRects[i], 255, i);
    }
  }
}

void draw()
{
  background(0); //clear background

  drawRect(input, #808080); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:    " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    rect(800, 00, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 100); //draw next label


    //my draw code

    textSize(70);
    textAlign(CENTER);
    //Draw letters
    for (int i = 0; i < 4; i++) {
      drawRect(rects[i], #FFFFFF, ""+letters[i]);
    }

    //Draw space and delete
    drawRect(delete, #FFFFFF, "del");
    drawRect(space, #FFFFFF, "_");
    textSize(30);
    //Draw scroll bar
    drawScroll(scroll, #FFFFFF);

    fill(0, 255, 0);
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void scrollPositionChanged()
{
  for (int i = 0; i < scrollRects.length; i++)
  {
    if (scrollRects[i].contains(mouseX, mouseY))
    {
      for (int j = 0; j < 4; j++) {
        letters[j] = lettersFull[i+j];
      }
      selectedScrollRectIndex = i;
      break;
    }
  }

}

void changeActiveLetters()
{
  lettersFull = commonLetters.get(lastTypedLetter);
  //System.out.println(Arrays.toString(lettersFull));
  //letters = Arrays.copyOfRange(lettersFull, 0, 3);
  for (int i = 0; i < 4; i++) {
    letters[i] = lettersFull[i];
  }
  // move red bar to beginning every time active letters change to avoid confusion
  selectedScrollRectIndex = 0;
}

void mousePressed()
{
  for (int i = 0; i < 4; i++) {
    if (rects[i].contains(mouseX, mouseY)) 
    {
      currentTyped += letters[i];
      lastTypedLetter = String.valueOf(letters[i]);
      changeActiveLetters();
    }
  }
  if (space.contains(mouseX, mouseY)) {
    currentTyped+=" ";
    lastTypedLetter = " ";
    changeActiveLetters();
  }
  if (delete.contains(mouseX, mouseY)) {
    if (currentTyped.length() > 0) 
    {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      if (currentTyped.length() == 0) lastTypedLetter = "";
      else lastTypedLetter = currentTyped.substring(currentTyped.length()-1); // get previously typed letter
    }
    changeActiveLetters();
  }
  
  scrollPositionChanged();

  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

int counter = 0;

void mouseDragged() 
{
  if (input.contains(mouseX, mouseY)) scrollPositionChanged();
  scrollLoc = mouseX;
}



void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}




//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}