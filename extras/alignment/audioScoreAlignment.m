% audioScoreAlignment
%
% Wrapper for linking the sections of the scores of different compositions
% to audio recording of the same composition. The methodology is explained
% in [1] using optimal parameters. During the process the tonic of the
% audio recording is also estimated by linking the repetitive section. See
% [2] for the methodology.
%
% In this experiment, the audio and the score are known to be of the same
% composition*. The score includes the musically relevant sections and their
% sequence in the composition. For candidate estimation, we use the class
% "@SectionCandidateLinkEstimator." The class links the given sections
% independent of each other. To follow the steps of how a single section
% is linked to the audio, please refer to "linkSingleScoreSectionDemo.m".
%
% After the candidate estimation a Variable-length Markov Model is trained
% to be used in the sequential linking step. The VLMM is trained on the
% annotated section sequences other audio recordings whose scores follow
% the same sequence with the current score. In the sequential linking step
% the most probable links from the section candidate links are selected
% according to the VLMM. We use the class "SequentialLinkEstimator" for
% sequential linking. To follow the steps of how the links are selected
% sequentially, please refer to "sequentialLinkingDemo.m".
%
% The score file is in symbTr format [3], which is a machine-readable
% format. The symbTr-score also includes the musically relevant structures
% (sections) of the compositions (in the lyrics colums). The audio features
% are extracted using Melodia [4] implementation in Essentia [5].
%
% Author: Sertan Senturk (sertan.senturk@upf.edu)
% Music Technology Group - Universitat Pompeu Fabra
% 2013
%
% References:
% [1] S. Senturk, A. Holzapfel, and X. Serra. Linking scores and audio
% recordings in makam music of Turkey. Journal of New Music Research,
% (submitted).
% [1] S. Senturk, S. Gulati, and X. Serra. Score Informed Tonic
% Identification for Makam Music of Turkey. In Proceedings of ISMIR, 2013.
% [3] K. Karaosmanoglu. A Turkish makam music symbolic database for music
% information retrieval: SymbTr. In Proceedings of ISMIR, pages 223-228,
% 2012.
% [4] J. Salamon and E. Gomez. Melody extraction from polyphonic music
% signals using pitch contour characteristics. IEEE Transactions on Audio,
% Speech, and Language Processing, 20(6):1759?1770, 2012.
% [5] D. Bogdanov, N. Wack, E. Gomez, S. Gulati, P. Herrera, O. Mayor, G.
% Roma, J. Salamon, J. Zapata, and X. Serra. Essentia: An audio analysis
% library for music information retrieval. In Proceedings of ISMIR, 2013.
%
% * The metadata is store as MBIDs. For further information refer to the
% relevant documentation in MusicBrainz.
% http://musicbrainz.org/doc/MusicBrainz_Identifier

%%
clear
clc
close all

%%
addpath(genpath(fullfile('..','..','code','fragmentLinker')))

%% open parpool if it doesn't exist
if isempty(gcp('nocreate')) % open the parpool
    parpool local
end

%% start experiment time
wrapperStart = tic;

%% parameters
dataFolder = '../../data/';

% these are problematic because the sarki repeats twice, it is not handled
% yet
problemFolder = {'nihavent--sarki--aksak--gel_guzelim--faiz_kapanci',...
    'huseyni--sarki--turkaksagi--hicran_oku--sevki_bey',...
    'ussak--sarki--aksak--bu_aksam_gun--tatyos_efendi',...
    'segah--sarki--curcuna--olmaz_ilac--haci_arif_bey'};

ignoreFolders = [{'excluded','postponed','checked','unchecked'} ...
    problemFolder];

%% parameters
options = {'TonicIdentificationMethod', 'scoreInformed', ...
    'TempoEstimationMethod', 'none', 'ScoreFormat', ...
    'generic', 'SectionCandidateEstimationMethod', 'dtw', ...
    'FilterKmeans', false, 'RemoveInconsequent', true, ...
    'GuessNonlinked', true, ...
    'Verbose', true, 'PlotSteps', false, ...
    'Write2File', false, 'OverwriteFile', false};
dtwOptions = {'DtwVariant', 'standard', 'DtwBandwidthRatio', .2, ...
    'DtwPixelsPitchDistanceBinarizationThreshold', feature...
    .PitchDataPoint(50, 'cent'), 'Verbose', true, 'Write2File', true,...
    'OverwriteFile', true, 'PlotSteps', false};

%% start repetitive section linking
disp(' ');disp('------------ Sequential Linking Wrapper -----------')

%% get the file locations
fileLocations = fragmentLinker.FileOperation.getAudioScorePairs(...
    dataFolder, 'wav', 'txt', ignoreFolders);

%% get training scores; related audio is handled inside
trainingFolder = '../../../../experiments/current/';
trainingLocations = fragmentLinker.FileOperation.getAudioScorePairs(...
    trainingFolder, 'wav', 'txt', ignoreFolders);
trainingScoreFiles = unique({trainingLocations.score});

annoFilenames = cellfun(@(x) fullfile(fileparts(x),'sectionLinks.json'),...
    {fileLocations.audio}, 'unif', false);

%% section linking
% instantiate the estimator objects
sectionLinker = makamLinker.SectionLinker(options);
link = @(score, audio, predominantMelody, tonic, tempo, training, ignore)...
    sectionLinker.link(score, audio, predominantMelody, tonic, tempo,...
    training, ignore);

aligner = fragmentLinker.NoteAligner(dtwOptions);
align = @(links, sections, audio) aligner.align(links, sections, audio);

% you can do parfor if you have parallel processing toolbox
% just uncomment the parpool block in the start and end of the script
% and replace the "for" with "parfor"
sectionLinks = cell(size(fileLocations));
alignedLinks = cell(size(fileLocations));
annotatedLinks = cell(size(fileLocations));
notes = cell(size(fileLocations));
info = cell(size(fileLocations));
parfor k = 1:length(fileLocations)
    %% print the experiment
    [~, audioname] = fileparts(fileLocations(k).audio);
    disp([num2str(k) ': ' audioname])
    
    %% section linking
    [candidateLinks{k}, sectionLinks{k}, info{k}, audio, sections] = link(...
        fileLocations(k).score, fileLocations(k).audio, '', '', '',...
        trainingScoreFiles, ignoreFolders);
    
    %% arrange annotated links
    annotatedLinks{k} = fragmentLinker.Link.readLinksFromJson(...
        annoFilenames{k}, 'annotation', [], [], []);
    
    % remove unrelated links
    annotatedLinks{k} = annotatedLinks{k}(~strcmp({annotatedLinks{k}.Label},...
        markov.VLMM.UNRELATED_STATE));
    
    for a = 1:length(annotatedLinks{k})
        % target
        annotatedLinks{k}(a).Target.source = sectionLinks{k}(1).Target.source;
        annotatedLinks{k}(a).Target.type = sectionLinks{k}(1).Target.type;
        annotatedLinks{k}(a).Target.featureName = sectionLinks{k}(1).Target.featureName;
        
        % query
        annotatedLinks{k}(a).Query = sectionLinks{k}(find(strcmp(...
            {sectionLinks{k}.Label}, annotatedLinks{k}(a).Label),1)).Query;
    end
    
    %% note alignment
    [notes{k}, alignedLinks{k}] = align(annotatedLinks{k}, sections, audio);
    
    %% convert hc to hz
    for nn = 1:numel(notes{k})
        notes{k}(nn).pitchHeight.Value = feature.Converter.hc2hz(...
            notes{k}(nn).pitchHeight.Value, audio.Features.tonic.Value);
        notes{k}(nn).pitchHeight.Unit = 'Hz';
    end
    
    % save notes 2 text
    noteTxtFilename = fullfile(fileparts(fileLocations(k).audio),...
        'alignedNotes.txt');
    matlab.note2text(notes{k}, noteTxtFilename)
end

%% evaluate
[candidateLinks, sectionLinks, ~, stat] = fragmentLinker...
    .Evaluator.evaluateSectionLinks(candidateLinks, sectionLinks, ...
    annoFilenames, info, true);

fragmentLinker.Evaluator.dispFragmentLinkEvaluation(stat, fileLocations)

%% close
toc(wrapperStart)
clear query target trainingScoreFiles
save('sectionLinking_all.mat')
fragmentLinker.buzz
delete(gcp('nocreate'))
