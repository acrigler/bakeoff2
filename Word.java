// word class - keeps data on POS, frequency, etc
public class Word {
	public String text;
	public int frequency;
	public String pos;
	public Word(String word, int frequency, String pos) {
		text = word;

	}	
	public String text() {
		return this.text;
	}
	
}