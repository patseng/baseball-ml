import sys


def convertToFloat(input_string):
	if '/' not in input_string:
		return float(input_string)
	else:
		index = input_string.index('/')
		return float(input_string[0:index]) / float(input_string[(index + 1):])

f = open(sys.argv[1])
lines = f.readlines()
f.close()
gammas = dict()
index = 0

while index < len(lines):
	line = lines[index]
	
	vals = line.split(',')

	vals[0] = convertToFloat(vals[0])
	vals[1] = convertToFloat(vals[1])
	vals[2] = convertToFloat(vals[2])

	if vals[0] not in gammas:
		gammas[vals[0]] = dict()

	gammas[vals[0]][vals[1]] = vals[2]

	index += 1

print sys.argv[2]

C_order = []

f = open(sys.argv[2], 'wb')
f.write('gamma')
gamma_keys = gammas.keys()
gamma_keys.sort()

for k in gamma_keys:
	C_order = gammas[k].keys()
	C_order.sort()

	for k2 in C_order:
		f.write(',' + str(k2))
	break

f.write('\n')

for k in gamma_keys:
	v = gammas[k]
	f.write(str(k))
	for c in C_order:
		f.write(',' + str(v[c]))
	f.write('\n')


f.close()
