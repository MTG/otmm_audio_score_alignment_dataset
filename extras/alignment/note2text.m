function note2text(notes, filename, tonicVal)
%NOTE2TEXT Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(filename, 'w');

formatSpec = '%f %f %f %s \n';

num_notes = numel(notes);
for r = 1:num_notes
    noteLabel = [notes(r).Symbol '-' notes(r).Label];
    noteLabel(strfind(noteLabel, ' ')) = '_';
    
    fprintf(fid,formatSpec,notes(r).Interval(1),notes(r).Interval(2),...
        feature.Converter.cent2hz(notes(r).Pitch.Value, tonicVal), ...
        noteLabel);
end
[~] = fclose(fid);
end
