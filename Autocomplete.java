import java.util.Arrays;
import java.util.Collections;
import java.nio.file.*;
import java.nio.charset.*;
import java.io.*;

public class Autocomplete {
	
	
	public static String[] getNCompletions(String input, int n) {
		String[] result = new String[n];
		if (n > 0) {
			//filler for now
			result[0] = input;
			if (n > 1) result[1] = "Hello, world!";

			/* method returns list of possible continuations - all words with up to some 
			 * threshold probability based on parts of speech, word frequencies, etc
			 */
			String[] completions = getBestCompletions(input);

			for (int i = 0; i < n; i++) {
				if (i < completions.length) {
					result[i] = completions[i];
				} else {	
					result[i] = "";
				}
			}

		}
		return result;
	}	

	public static String[] getBestCompletions(String input) {
		String[] completions = new String[100];
		for (int i = 0; i < input.length(); i++){
			completions[i] = input.substring(i, i+1);
		}
		return completions;
	}
	public static Trie createTrieFromFile(String filename) {
		Charset charset = Charset.forName("US-ASCII");
		Path file = Paths.get("/Users/ameliacrigler/Documents/05391/bakeoff2/data/wordlist2.txt").toAbsolutePath();
		Trie t = new Trie();
		try (BufferedReader reader = Files.newBufferedReader(file, charset)) {
    		String line = null;
    		while ((line = reader.readLine()) != null ) {
    			String text = "";
    			for (char c : line.toCharArray()) {
    				if ('a' <= c && c <= 'z') 
	    				text += c;
    			}
    			
        		t.add(new Word(text, 0, "NN"));
        		
		    }
		} catch (IOException x) {
    		System.err.format("IOException: %s%n", x);
		}
		return t;

	}
	public static Trie initializeTestTrie() {
		Word[] wordlist = new Word[3];

		wordlist[0] = new Word("abc", 3, "NN");
		wordlist[1] = new Word("abe", 6, "PP");
		wordlist[2] = new Word("efg", 2, "NN");
		Trie t = new Trie();
		t.addList(wordlist);
		return t;
	}
}