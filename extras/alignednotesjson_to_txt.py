
# coding: utf-8

# In[4]:

import json
import  csv

recID = '92ef6776-09fa-41be-8661-025f9b33be4f'
notes_URI = '/Users/joro/Downloads/derivedfiles_' + recID + '/jointanalysis-notes-1-1.json'
symbTrName = 'ussak--sarki--duyek--aksam_oldu_huzunlendim--semahat_ozdenses'
notes = json.load(open(notes_URI))

URI_notes_aligned = '../data/' + symbTrName + '/' + recID + '/alignedNotes.txt' # convetion name for this repo 
writer = csv.writer(open(URI_notes_aligned,'wb'), delimiter='\t')
workID = 'c6e43ac6-4a18-42ab-bcc4-46e29360051e' # TODO: use mb to get work
work_notes = notes[workID]

for note in work_notes:
    
    times = note['interval']
    times[0] -= 32.04
    times[1] -= 32.04
    row = times
    
    row.append(note['performed_pitch']['value'])
    print row
    writer.writerow(row)

# In[ ]:



