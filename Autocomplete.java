import java.util.Arrays;
import java.util.Collections;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Set;
 
public class Autocomplete {
	
	Trie trie = new Trie();
	String[] currentOptions;
	int n;
	public Autocomplete(int n) {
		currentOptions = new String[n];
		this.n = n;
		for (int i = 0; i < n; i++) {
			currentOptions[i] = "";
		}

	}
	public void addWords(String[] words) {
		for (String word : words) {

    		String text = "";
    		for (char c : word.toCharArray()) {
    			if ('a' <= c && c <= 'z') 
	    			text += c;
    			}
    			
        	this.trie.add(new Word(text, 0, "NN"));
        		
		    }

	}

	public void getCompletions(String input) {
		this.currentOptions[0] = "HI";
		if (this.n > 0) {			

			/* method returns list of possible continuations - all words with up to some 
			 * threshold probability based on parts of speech, word frequencies, etc
			 */
			Map<Word, Integer> completionsMap = this.trie.findWords(input, this.n);
			
			
			Word[] completions = completionsMap.keySet().toArray(new Word[completionsMap.size()]);
			for (int i = 0; i < this.n; i++) {
				if (i < completions.length) {
					this.currentOptions[i] = completions[i].text;
				} else {	
					this.currentOptions[i] = "";
				}
			}
	
		}

		
	}	

	public String[] getBestCompletions(String input) {
		String[] completions = new String[100];
		for (int i = 0; i < input.length(); i++){
			completions[i] = input.substring(i, i+1);
		}
		return completions;
	}

}