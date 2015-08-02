function note2text(notes, filename)
%NOTE2TEXT Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(filename, 'w');

formatSpec = '%f %f %f %s \n';

num_notes = numel(notes);
for r = 1:num_notes
    noteLabel = [notes(r).symbol '-' notes(r).label];
    noteLabel(strfind(noteLabel, ' ')) = '_';
    
    fprintf(fid,formatSpec,notes(r).interval(1),notes(r).interval(2),...
        notes(r).pitchHeight.Value, noteLabel);
end
[~] = fclose(fid);
end
