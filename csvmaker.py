import sys


original = open(sys.argv[1], "rb", 0)
output = open(sys.argv[2], "w")
for line in original:
	tokens = line.split(':')
	readings = tokens[3].strip().split(' ')
	for x in readings:
		output.write(x + ',')
output.close()
