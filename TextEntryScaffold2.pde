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
final int DPIofYourDeviceScreen = 424; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
final int tw = sizeOfInputArea/12; //Used because fractions confuse me
final int margin = 300;
int buttonMarginBottom = tw / 4;
int buttonMarginHalf = tw / 8;

int scrollLoc = 0;
Rect input = new Rect(
                      margin, 
                      margin, 
                      margin + tw*12, 
                      margin + tw*12
                      );
                      
Rect leftMask = new Rect(
                          margin - tw*12,
                          margin,
                          margin,
                          margin + tw*12
                          );
Rect rightMask = new Rect(
                          margin + tw*12,
                          margin,
                          margin + tw*12 * 2,
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

Rect[] qwerty = new Rect[26];

//char[] alphabet = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
char[] lettersFull = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
char[] letters = {'a', 'b', 'c', 'd'};
String lastTypedLetter = "";
Map<String, char[]> commonLetters = new HashMap<String, char[]>();
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  // draw qwerty keyboard
  int rows = 3;
  int marginTop = margin + delete.height() + buttonMarginBottom;
  int oldMarginLeft = margin - (tw*12/2); 
  int marginLeft = margin - (tw*12/2); 
  int keyCount = 0;
  int numKeys = 10;
  for (int i = 0; i < rows; i++)
  {
    if (i == 0) numKeys = 10;
    else if (i == 1) numKeys = 9;
    else if (i == 2) numKeys = 7;
    for (int j = 0; j < numKeys; j++)
    {
      qwerty[keyCount] = new Rect(
                                  marginLeft,
                                  marginTop,
                                  marginLeft + tw*2,
                                  marginTop + tw*2
                                  );
      marginLeft += (tw*2 + buttonMarginHalf * 2);
    }
    marginTop += (tw*2 + buttonMarginBottom);
    // reset marginLeft
    marginLeft = oldMarginLeft + tw;
  }
  
  // can't map char as key, so need to cast when checking previous letter
  commonLetters.put("", new char[] {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put(" ", new char[] {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  
  commonLetters.put("a", new char[] {'n', 'r', 't', 'l', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("c", new char[] {'o', 'a', 'h', 'e', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("b", new char[] {'a', 'e', 'l', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("e", new char[] {'r', 's', 'n', 'd', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("d", new char[] {'e', 'i', 'a', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("g", new char[] {'e', 'a', 'r', 'i', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("f", new char[] {'i', 'o', 'e', 'a', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("i", new char[] {'n', 's', 'c', 't', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("h", new char[] {'e', 'a', 'o', 'i', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("k", new char[] {'e', 'i', 'a', 's', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("j", new char[] {'a', 'o', 'e', 'u', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("m", new char[] {'a', 'e', 'i', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("l", new char[] {'e', 'i', 'a', 'l', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("o", new char[] {'n', 'r', 'l', 'u', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("n", new char[] {'g', 'e', 't', 'a', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("q", new char[] {'u', 'i', 'a', 's', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("p", new char[] {'e', 'a', 'r', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("s", new char[] {'t', 'e', 'i', 's', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("r", new char[] {'e', 'a', 'i', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("u", new char[] {'r', 'n', 's', 'l', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("t", new char[] {'e', 'i', 'a', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("w", new char[] {'a', 'e', 'i', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("v", new char[] {'e', 'i', 'a', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("y", new char[] {'s', 'a', 'n', 'e', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("x", new char[] {'i', 't', 'p', 'e', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});
  commonLetters.put("z", new char[] {'e', 'a', 'i', 'o', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});

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

void drawRect(Rect r, int hex, String input) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY()+25); //
}

void draw()
{
  background(0); //clear background

  drawRect(leftMask, 255);
  drawRect(rightMask, 255);
  drawRect(input, #808080); //input area should be 2" by 2"
  
  for (int i = 0; i < qwerty.length; i++) 
  {
    System.out.println(qwerty[i]);
    //drawRect(qwerty[i], 0);
  }

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
    //for (int i = 0; i < 4; i++) {
    //  drawRect(rects[i], #FFFFFF, ""+letters[i]);
    //}

    //Draw space and delete
    drawRect(delete, #FFFFFF, "del");
    drawRect(space, #FFFFFF, "_");
    textSize(30);
    //Draw scroll bar

    fill(0, 255, 0);
  }
  
  //drawRect(leftMask, 0);
  //drawRect(rightMask, 0);
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void scrollPositionChanged()
{
  //for (int i = 0; i < scrollRects.length; i++)
  //{
  //  if (scrollRects[i].contains(mouseX, mouseY))
  //  {
  //    for (int j = 0; j < 4; j++) {
  //      letters[j] = lettersFull[i+j];
  //    }
  //    selectedScrollRectIndex = i;
  //    break;
  //  }
  //}

}

void changeActiveLetters()
{
  //lettersFull = commonLetters.get(lastTypedLetter);
  //System.out.println(Arrays.toString(lettersFull));
  //letters = Arrays.copyOfRange(lettersFull, 0, 3);
  
  for (int i = 0; i < 4; i++) {
    letters[i] = commonLetters.get(lastTypedLetter)[i];
  }
}

void mousePressed()
{
  for (int i = 0; i < 4; i++) {
    
  }
  if (space.contains(mouseX, mouseY)) {
    currentTyped+=" ";
    //lastTypedLetter = " ";
    //changeActiveLetters();
  }
  if (delete.contains(mouseX, mouseY)) {
    if (currentTyped.length() > 0) 
    {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      //if (currentTyped.length() == 0) lastTypedLetter = "";
      //else lastTypedLetter = currentTyped.substring(currentTyped.length()-1); // get previously typed letter
    }
    //changeActiveLetters();
  }
  

  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

int counter = 0;

void mouseDragged() 
{
  //if (input.contains(mouseX, mouseY)) scrollPositionChanged();
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