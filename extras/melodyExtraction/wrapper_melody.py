# -*- coding: utf-8 -*-

from compmusic.extractors.makam import pitch
from FileOperations import getFileNamesInDir
import os 
import json
import scipy, numpy

extractor = pitch.PitchExtractMakam()

audioDir = '../../data' # audio folder and subfolders
audioDir = '/home/sertansenturk/Documents/notaIcra/code/svg-alignment-test'

# always convert to wav first and use it to avoid the delays introduced by
# encoder/decoderss
audioFiles = getFileNamesInDir(audioDir, audio_ext=".wav")[0]

matfiles = [os.path.dirname(f) + '/predominantMelody.mat' for f in audioFiles] # json file; loaded from the settings and pitch
jsonfiles = [os.path.dirname(f) + '/predominantMelody.json' for f in audioFiles] # matlab file
txtfiles = [os.path.dirname(f) + '/predominantMelody.txt' for f in audioFiles] # text file; for sonic visualizer

for ii, audio in enumerate(audioFiles):
	print ' '
	print str(ii+1) + ": " + os.path.basename(audio)

	results = extractor.run(audio)
	pitch = json.loads(results['pitch'])

	'''
	# json file; loaded from the settings and pitch
	jsondata = json.loads(results['settings'])
	jsondata['pitch'] = pitch
	with open(jsonfiles[ii], 'w') as f:
		json.dump(jsondata, f)

	
	# matlab file
	with open(matfiles[ii], 'w') as f:
		f.write(results['matlab'])
	'''

	# text file; for sonic visualizer
	with open(txtfiles[ii], 'w') as f:
		numpy.savetxt(f, pitch)
