import os.path
import sys


def visit(arg, dirname, names):
	for name in names:
		if os.path.isfile(os.path.join(dirname, name)):
			f = open(os.path.join(dirname, name))
			lines = f.readlines()
			f.close()
			f = open(os.path.join(dirname, name), 'w')
			for line in lines:
				if not line.startswith('com'):
					f.write(line)



os.path.walk(sys.argv[1], visit, [])
