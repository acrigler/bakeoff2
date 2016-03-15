import json
from operator import itemgetter

"""
Probably start out by providing top 4-5 most common starting letters in English first
a la http://scottbryce.com/cryptograms/stats.htm
"""

def writeToJSON():

	letters = {}
	alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
	for char in alphabet:
		letters[char] = []
		for char2 in alphabet:
			letters[char].append([char2, 0])
	with open("100k.txt", "r") as f:
		counter = 0
		for line in f:
			cleanLine = line.split("\t")[0].lower()
			for i in xrange(len(cleanLine)):
				# Check current and next letter
				if i < len(cleanLine) - 1:
					currentLetter = cleanLine[i]
					nextLetter = cleanLine[i+1]
					# if currentLetter not in letters: letters[currentLetter] = []
					# search through array of following letters (only array to allow sorting)
					# exists = False
					for l in letters[currentLetter]:
						if l[0] == nextLetter:
							l[1] += 1
							# exists = True
							break
					# if not exists: letters[currentLetter].append([nextLetter, 1])
					# if nextLetter not in letters[currentLetter]: letters[currentLetter][nextLetter] = 1
					# else: letters[currentLetter][nextLetter] += 1


			print cleanLine
			counter += 1
			# if counter == 5000:
				# break

		for letter in letters:
			letters[letter].sort(key=lambda x: int(x[1]), reverse=True)


		formatAsJava(letters)

		# for storage purposes
		with open("results.json", "w") as fp:
			fp.write(json.dumps(letters, indent=2))

def formatAsJava(letters):
	"""
	Style:
	commonLetters.put("c", new char[] {'m','l'});
	"""
	code = ""
	with open("fakejava2.txt", "w") as f:
		for letter in letters:
			code += "commonLetters.put(\"%s\", new char[] {" % (letter)
			for i in xrange(4):
				code += "'%s', " % (letters[letter][i][0]) # letter itself
			#	code += "'%s'" % (letters[letter][i][0]) # letter itself
			# 	if i < len(letters[letter]) - 1:
			# 		code += ", "
			# code += "});\n"
			# normal alphabet after first 4
			code += "'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'});\n"
		f.write(code)


writeToJSON()
