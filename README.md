turkish_makam_audio_score_alignment_dataset
================================================

Variant of the makam audio score alignment dataset with manually corrected annotaitons of vocal

The repository is structured as:

	/symbTr-score/audio-mbid

where _symbTr-score_ is the unique score obtained from the SymbTr database and _audio-mbid_ stands for the unique MusicBrainz ID (https://musicbrainz.org/doc/MusicBrainz_Identifier). 

In each _symbtr-score_ folder, there are three files:

- The machine-readable SymbTr-score in __text format__.
- The __pdf__ of the SymbTr-score
- __scoreMetadata.json__ storing structured metadata about the SymbTr-score.

In each audio-mbid folder, there are  files:

- onsetAnnotations.txt - 
	Added in this branch to store vocal  onsets. Some (but not all) non-vocal onsets are deleted. 
	NOTE: if a syllable starts with unvoied sound, onsets is annotated at the beginning of the voiced part (e.g.  'Shi'  will have the onset beginning at i). However, if a background instrument plays same pitch simultaneously to voice, the onset of the instrument is marked as if it were the vocal onset.
	NOTE: notes stored as regions for consistency with noteAnnotations.txt. However only onsets are checked, so some offsets might not make sense. 

- __noteAnnotations.txt__ stores the manually aligned notes. The first column is the onset time in seconds, second is the note symbol ("*Nota53*" column in the SymbTr-score) and the third indicates the note index in the corresponding SymbTr-score (i.e. the indices given in the first column of the SymbTr-score, named "*Sira*").
- __tonic.json__ stores the annotated tonic.
- __sectionLinks.json__ stores the annotated sections. The audio is divided into sections as given in the corresponding SymbTr-score.

