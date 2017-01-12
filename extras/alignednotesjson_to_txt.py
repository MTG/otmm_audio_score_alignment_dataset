
# coding: utf-8

# In[4]:

import json
import  csv
import os

recID = '92ef6776-09fa-41be-8661-025f9b33be4f'
symbTrName = 'ussak--sarki--duyek--aksam_oldu_huzunlendim--semahat_ozdenses'
workID = 'c6e43ac6-4a18-42ab-bcc4-46e29360051e' # TODO: use mb to get work

recID = 'c7a31756-a7d5-4882-bdf7-9c6b23493597' # TODO
symbTrName = 'rast--sarki--duyek--hicran_olacaksa--ferit_sidal' # TODO
workID = '5f7c74b7-8af6-4ab7-a504-f694bbd347e9' # TODO: use mb to get work


notes_URI = '/Users/joro/Downloads/derivedfiles_' + recID + '/jointanalysis-notes-1-1.json'


#### create recording dir
notes = json.load(open(notes_URI))
symbTr_dir = '/Users/joro/Documents/Phd/UPF/turkish_makam_audio_score_alignment_dataset/data/' + symbTrName
if not os.path.isdir(symbTr_dir):
	os.mkdir(symbTr_dir)
recID_dir = symbTr_dir + '/' + recID
if not os.path.isdir(recID_dir):
	os.mkdir(recID_dir)
URI_notes_aligned_output = os.path.join(recID_dir,'alignedNotes.txt') # convetion name for this repo 
writer = csv.writer(open(URI_notes_aligned_output,'wb'), delimiter='\t')
work_notes = notes[workID]

for note in work_notes: # read intercvals
    
    times = note['interval']
    # times[0] -= 32.04
    # times[1] -= 32.04
    row = times
    
    row.append(note['performed_pitch']['value'])
    print row
    writer.writerow(row)

# In[ ]:



