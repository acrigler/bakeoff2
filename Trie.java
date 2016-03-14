import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
//trie implementation

public class Trie { 
	private static int charToIndex(char c) {
		return (int)c - (int)'a';
	}
	class Node {
		Set<Word> words = new HashSet<Word>();
		Node[] children = new Node[26];
		Map<String, Integer> childBests = new HashMap<String, Integer>();

		
		private void updateChildBests(String pos, int freq) {
			if (this.childBests.get(pos) == null || this.childBests.get(pos) < freq) {
				this.childBests.put(pos, freq);
			}
		}

		private Node getChildNode(char c) {
			return this.children[charToIndex(c)];
		}
		private void add(Word w, int i) {
			if (i == w.text.length()) {
				//end of word -> add to words ending at this node
				this.words.add(w);
			} 
			else if (i < w.text.length()) {
				this.updateChildBests(w.pos, w.frequency);
				char c = w.text.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) {
					this.children[charToIndex(c)] = new Node();
					child = this.children[charToIndex(c)];
				}
				child.add(w, i+1);
			}


		}
		private boolean lookupFromNode(String word, int i) {
			if (i == word.length()) {
				return (! this.words.isEmpty());
			} else {
				char c = word.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) return false;
				else {
					return child.lookupFromNode(word, i+1);
				}
			}
		}
		private Map<Word, Integer> traverseFindWords(String prefix, int i, int minWords, Map<Word, Integer> wordsFound) {
			if (i == prefix.length() && wordsFound.size() < minWords) {
				if (this.words.size() > 0) {
					System.out.println("found word: ");
					for (Word w : this.words) {
						System.out.println(w.text);
						wordsFound.put(w, 0);
					}
					if (wordsFound.size() >= minWords) return wordsFound;
				}
				for (int j = 0; j < 26; j++) {
					Node child = this.children[j];
					if (child == null) continue;
					else {
						System.out.println("trying " + (char)(j + 'a'));
						wordsFound = child.traverseFindWords(prefix, i, minWords, wordsFound);
						if (wordsFound.size() >= minWords) return wordsFound;
					}
				}
				return wordsFound;
			} else {
				char c = prefix.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) return wordsFound;
				else return child.traverseFindWords(prefix, i+1, minWords, wordsFound);
			}
		}
	}
	Node root;
	public Trie() {
		root = new Node();
	}
	public void addList(Word[] words) {
		for (int i = 0; i < words.length; i++) {
			this.add(words[i]);
		}
	}
	public void add(Word w) {
		this.root.add(w, 0);
	}
	
	public boolean inTrie(String word) {
		return this.root.lookupFromNode(word, 0);
	}

	public Map<Word, Integer> findWords(String prefix, int n) {
		Map<Word,Integer> words = new HashMap<Word,Integer>();
		return this.root.traverseFindWords(prefix, 0, n, words);
	}
}
	