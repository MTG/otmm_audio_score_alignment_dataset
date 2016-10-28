otmm_audio_score_alignment_dataset
================================================

__The Audio Score Alignment Test Datasets for Ottoman-Turkish makam music__

The repository includes the test datasets used in various audio-score alignment experiments on Ottoman-Turkish makam music. 

This particular release contains the audio-score alignment test dataset used in the paper:

> Şentürk, S., Gulati, S., and Serra, X. (2014). Towards alignment of score and audio recordings of Ottoman-Turkish makam music. In Proceedings of 4th International Workshop on Folk Music Analysis, pages 57–60, Istanbul, Turkey.

The dataset in this release is derived from the transcription test dataset used in the paper: 

> Benetos, E. & Holzapfel, A. (2013). Automatic transcription of Turkish makam music. In Proceedings of 14th International Society for Music Information Retrieval Conference, 4 - 8 Nov 2013, Curitiba, PR, Brazil.

The scores are from the SymbTr database. The database is explained in:

> Karaosmanoğlu, K. (2012). A Turkish makam music symbolic database for music information retrieval: SymbTr. In Proceedings of 13th International Society for Music Information Retrieval Conference (ISMIR), pages 223–228.

Please __cite__ the works above if you are using this release. Please check the releases page (https://github.com/sertansenturk/turkish_makam_audio_score_alignment_dataset/releases) for other datasets.

The repository is structured as:

	/symbTr-score/audio-mbid

where _symbTr-score_ is the unique score obtained from the SymbTr database and _audio-mbid_ stands for the unique MusicBrainz ID (https://musicbrainz.org/doc/MusicBrainz_Identifier). 

In each _symbtr-score_ folder, there are three files:

- The machine-readable SymbTr-score in __text format__.
- The __pdf__ of the SymbTr-score
- __scoreMetadata.json__ storing structured metadata about the SymbTr-score.

In each audio-mbid folder, there are three files:

- __noteAnnotations.txt__ stores the manually aligned notes. The first column is the onset time in seconds, second is the note symbol ("*Nota53*" column in the SymbTr-score) and the third indicates the note index in the corresponding SymbTr-score (i.e. the indices given in the first column of the SymbTr-score, named "*Sira*").
- __tonic.json__ stores the annotated tonic.
- __sectionLinks.json__ stores the annotated sections. The audio is divided into sections as given in the corresponding SymbTr-score.

