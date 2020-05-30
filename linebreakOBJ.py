import os
import re

def linebreak(line, charMax):
	input = line
	breakstr = "|"
	
	suspendCount = 0
	n = 0
	lastSpace = 0
	charcount = 1
	extraspace = 0

	while n < len(input):
		charcount = charcount + 1
		if input[n] == " ":
			lastSpace = n
		if input[n] == "|":
			charcount = 1
			n = n+1
		if charcount > charMax and lastSpace != 0:
			input = input[0:lastSpace] + breakstr + input[lastSpace+1::]
			charcount = 0
			n = -1
		n = n+1
		
	return input

#Check overflow

##----------------------------------

f='shc/ExEvntA.txt'

f_in = open(f)
f_out = open('OUT.txt',"w")
print f
print "------------------------"
charMax = 31
i = 0
for line in f_in:
	if (i == 4):
		print line
		line = linebreak(line, charMax)
		i=-1
	f_out.write(line)
	i = i+1
	


	
	