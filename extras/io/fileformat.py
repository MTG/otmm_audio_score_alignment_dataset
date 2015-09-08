import csv
import json

def tsv2json(tsvfile, jsonfile):
	sectionAnnos = {'annotations': list()}
	with open(tsvfile) as tsv:
	    for line in csv.reader(tsv, dialect="excel-tab"):
	    	element = {'name': line[2],  'time_unit': "sec",
	    			   'time':[float(f) for f in line[0:2]]}
	    	sectionAnnos['annotations'].append(element)

	with open(jsonfile, 'w') as outfile:
	    json.dump(sectionAnnos, outfile, indent=4)