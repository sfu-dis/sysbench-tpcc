#! /bin/python3
# Reads a file with a number in each line and calculates the mean
import sys
summ = 0.0
i=0

with open(sys.argv[1], 'r') as file:
	for n in file:
		summ += float(n)
		i+=1

print('{:.5f}'.format((summ/i)))
