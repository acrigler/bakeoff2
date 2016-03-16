import java.util.Arrays;
import java.util.Collections;
import android.graphics.Rect;
import java.util.Map;
import java.util.HashMap;
import android.text.TextUtils;


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
//boolean dragging = false;
//Instead of boolean, use total distance from press to release to determine if dragged
float initX, initY;

// comment this out to disable highlighting of suggested next letters
// only highlights 4 because I haven't written code that writes the entire CommonLetters.java class yet (manually broken up put calls)
boolean showSuggested = true;
String suggestionKey;

int scrollLoc = 0;
Rect input = new Rect(
                      margin, 
                      margin , 
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
                       margin + tw*10, 
                       margin + tw*6 - buttonMarginHalf, 
                       margin + tw * 12 - buttonMarginBottom
                       );
Rect space = new Rect(
                      margin + tw * 6 + buttonMarginHalf, 
                      margin + tw*10, 
                      margin + tw * 12, 
                      margin + tw * 12 - buttonMarginBottom
                      );
                      
Rect[] auto = new Rect[4];


int numAutocompleteOptions = 4;
String[] wordlist;
Autocomplete autocomplete;
Rect qwertyBox;

Rect[] qwerty = new Rect[26];
char[] firstQwertyRow = {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'};
char[] secondQwertyRow = {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'};
char[] thirdQwertyRow = {'z', 'x', 'c', 'v', 'b', 'n', 'm'};
String keyLetter;

//char[] alphabet = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
char[] lettersFull = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
char[] letters = {'a', 'b', 'c', 'd'};
String lastTypedLetter = "";
Map<String, char[]> commonLetters = CommonLetters.getCommonLetters();
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  // draw autocomplete options
  autocomplete = new Autocomplete(4);
  autocomplete.addWords(loadStrings("worddata.txt"));
  auto[0] = new Rect(margin, margin, margin + tw*6, margin + tw*2 - tw/2);
  auto[1] = new Rect(margin + tw*6, margin, margin + tw*12, margin +tw*2 - tw/2);
  auto[2] = new Rect(margin, margin + tw*2 - tw/2, margin + tw * 6, margin + tw*3);
  auto[3] = new Rect(margin + tw*6, margin + tw*2 - tw/2, margin + tw*12, margin + tw*3 ); 
  // draw qwerty keyboard
  int rows = 3;
  int marginTop = margin + 2*auto[0].height() + buttonMarginBottom; // change this to move whole qwerty keyboard
  // initialize qwerty drag box based on marginTop (assumes height of 3 * tw*2 + 2 * buttonMarginBottom)
  qwertyBox = new Rect(
                        margin,
                        marginTop,
                        margin + tw*12,
                        marginTop + 3 * tw*2 + 2 * buttonMarginBottom
                        );
  
  
  
  int oldMarginLeft = margin - (tw*12/2); 
  int marginLeft = margin - (tw*12/2); 
  int keyCount = 0;
  char[] qwertyRow = firstQwertyRow;
  for (int i = 0; i < rows; i++)
  {
    if (i == 0) qwertyRow = firstQwertyRow; // redundant
    else if (i == 1) qwertyRow = secondQwertyRow;
    else if (i == 2) qwertyRow = thirdQwertyRow;
    for (int j = 0; j < qwertyRow.length; j++)
    {
      qwerty[keyCount] = new Rect(
                                  marginLeft,
                                  marginTop,
                                  marginLeft + tw*2,
                                  marginTop + tw*2
                                  );
      marginLeft += (tw*2 + buttonMarginHalf * 2);
      keyCount++;
    }
    marginTop += (tw*2 + buttonMarginBottom);
    // reset marginLeft
    if (i == 0) marginLeft = oldMarginLeft + tw + buttonMarginHalf*2;
    else if (i == 1) marginLeft = oldMarginLeft + tw*3 + buttonMarginHalf*4;
  }
  
  System.out.println(commonLetters.get("a"));
  System.out.println(commonLetters.get("th"));

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

void drawInvisibleRect(Rect r) {
  noFill();
  noStroke();
  rect((float)r.left, (float)r.top, (float)r.width(), (float)r.height());
}

void drawRect(Rect r, int hex, String input, int marginTop) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY() + marginTop); //
}

void draw()
{
  background(0); //clear background

  //drawRect(leftMask, 255); // for debug
  //drawRect(rightMask, 255);
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
    //for (int i = 0; i < 4; i++) {
    //  drawRect(rects[i], #FFFFFF, ""+letters[i]);
    //}

    //Draw space and delete
    drawRect(delete, #FFFFFF, "del", 25);
    drawRect(space, #FFFFFF, "_", 20);
    textSize(36);
    
    for (int i = 0; i < qwerty.length; i++) 
    {
      findKeyLetter(i);
      // highlight if suggested
      if (showSuggested) drawSuggested(i);
      else drawRect(qwerty[i], 255, keyLetter, 12);
    }
    //drawInvisibleRect(qwertyBox);

    fill(0, 255, 0);
  }
  //draw autocomplete options
  textSize(40);
  for (int i = 0; i < 4; i++) {
    drawRect(auto[i], #FFFFFF,   autocomplete.currentOptions[i], tw/5 );
  }

  
  drawRect(leftMask, 0);
  drawRect(rightMask, 0);
}

void drawSuggested(int i)
{
  // check whether suggestions can be made for 1 or 2 letters
  if (currentTyped.length() > 0 && !" ".equals(String.valueOf(currentTyped.charAt(currentTyped.length()-1))))
  {
    // suggestions can be made for 2 letters
    if (currentTyped.length() >= 2 && !" ".equals(String.valueOf(currentTyped.charAt(currentTyped.length()-2))))
    {
      int lowerBound = 0;
      if (currentTyped.length() > 2) lowerBound = currentTyped.charAt(currentTyped.length()-3); // can sometimes still be 0
      suggestionKey = String.valueOf(currentTyped.charAt(currentTyped.length()-2)) + String.valueOf(currentTyped.charAt(currentTyped.length()-1));
    }
    // suggestions can be made for 1 letter
    else suggestionKey = String.valueOf(currentTyped.charAt(currentTyped.length()-1));
  }
  // can't make suggestions for 1 or 2 letters
  else suggestionKey = ""; // (not a real key)
  
  // loop through suggestions and color accordingly
  if (suggestionKey.length() > 0)
  {
    char[] asl = commonLetters.get(suggestionKey);
    boolean letterWasSuggested = false;
    for (int j = 0; j < 4; j++)
    {
      if (keyLetter.equals(String.valueOf(asl[j])))
      {
        drawRect(qwerty[i], #E7FC28, keyLetter, 12);
        letterWasSuggested = true;
        break;
      }
    }
    if (!letterWasSuggested) drawRect(qwerty[i], 255, keyLetter, 12);
  }
  else drawRect(qwerty[i], 255, keyLetter, 12);
}

// because I did this poorly
void findKeyLetter(int i)
{
  if (i < firstQwertyRow.length) keyLetter = String.valueOf(firstQwertyRow[i]);
  else if (i < firstQwertyRow.length + secondQwertyRow.length) keyLetter = String.valueOf(secondQwertyRow[i-firstQwertyRow.length]);
  else if (i < firstQwertyRow.length + secondQwertyRow.length + thirdQwertyRow.length) keyLetter = String.valueOf(thirdQwertyRow[i-firstQwertyRow.length-secondQwertyRow.length]);
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void scrollPositionChanged()
{
  
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

void mouseReleased()
{
  if (dist(mouseX,mouseY,initX,initY) < tw/2 && !leftMask.contains(mouseX, mouseY) && !rightMask.contains(mouseX, mouseY)) // don't let keys be pressed when they are masked
  {
    for (int i = 0; i < qwerty.length; i++)
    {
     if (qwerty[i].contains(mouseX, mouseY))
     {
       findKeyLetter(i);
       currentTyped += keyLetter;
       callAutocorrect();
       break;
     }
    }
  }
}

void mousePressed()
{

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
  for (int i = 0 ; i < numAutocompleteOptions; i++ ) {
    if (auto[i].contains(mouseX, mouseY)) addRestOfWord(i);
  }
  if (currentTyped.length() > 0) callAutocorrect();
  
  initX = mouseX;
  initY = mouseY;
 

  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}
void addRestOfWord(int i) {
  String[] words = currentTyped.split(" ");
  words[words.length-1] = autocomplete.currentOptions[i];
  currentTyped = TextUtils.join(" ", words);
  callAutocorrect();
}
int counter = 0;

void mouseDragged() 
{
  //if (input.contains(mouseX, mouseY)) scrollPositionChanged();
  //scrollLoc = mouseX;
  if (qwertyBox.contains(mouseX, mouseY)) 
  {
    // shift all key rects
    int difference = mouseX - pmouseX;
    // set bounds on movement
    if (qwerty[0].left + difference <= margin && qwerty[9].right + difference >= margin + tw*12)
    {
      for (int i = 0; i < qwerty.length; i++)
      {
        qwerty[i].left += difference;
        qwerty[i].right += difference;
      }
    }
  }
}

String currentWord(String typed) {
  if (typed.charAt(typed.length()-1) == ' ') return "";
  String[] words = typed.split(" ");
  System.out.println(words[words.length-1]);
  return words[words.length - 1];
}


void callAutocorrect() {
  String word = currentWord(currentTyped);
  if (word != "") {
    autocomplete.getCompletions(word);
  } else {
    for (int i = 0; i < numAutocompleteOptions; i++) {
      autocomplete.currentOptions[i] = "";
    }
  }
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