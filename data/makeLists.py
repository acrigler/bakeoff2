import os, string

with open("wordlist2.txt") as f:
	curletters = "aa"
	wordlist = ""
	for word in f.readlines():
		if word[0:2] != curletters:
			with open("lists/" + curletters + ".txt", "w") as g:
				g.write(wordlist)
			wordlist = word
			curletters = word[0:2]
		else: 
			wordlist += word
	with open("lists/" + curletters + ".txt", "w") as g:
		g.write(wordlist)


