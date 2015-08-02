import os 
def getFileNamesInDir(dir_name, audio_ext = '.mp3', skip_foldername = ''):
	names = []
	folders = []
	fullnames = []
	print dir_name
	for (path, dirs, files) in os.walk(dir_name):
		for f in files:
			if f.lower()[-4:] == audio_ext:
				if skip_foldername not in path.split(os.sep)[1:]:
					folders.append(unicode(path, 'utf-8'))
					names.append(unicode(f,'utf-8'))
					fullnames.append(os.path.join(path,f))

	print "> Found " + str(len(names)) + " files."
	return fullnames, folders, names

def getOutputTemplate(audioFile, outBaseDir, audioBaseDir):
	template = os.path.join(outBaseDir, audioFile[len(audioBaseDir):-(len(os.path.splitext(audioFile)[1]))])
	return template

def getOutputFiles(template, overwriteExisting):
	template_dir = os.path.dirname(template)
	out_json = template + '.json'
	out_mat = template + '.mat'

	if not os.path.exists(template_dir):
		os.makedirs(template_dir)
	elif not os.path.exists(out_json) or overwriteExisting:
		pass
	else:
		out_json = None
		out_mat = None

	return out_json, out_mat
