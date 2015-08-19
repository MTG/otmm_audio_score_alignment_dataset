% sectionLinkingWrapper
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

addpath('../../../../code/fragmentLinker')

%% open parpool if it doesn't exist
% if isempty(gcp('nocreate')) % open the parpool
%     parpool local
% end

%% start experiment time
wrapperStart = tic;

%% parameters
dataFolder = '../../data/';

ignoreFolders = {'excluded','postponed','checked','unchecked'};

% default options
options = {'ScoreFormat', 'generic', 'Verbose', false, 'PlotSteps', true,...
    'TempoMethod', 'none', 'Method', 'scoreInformed',...
    'CandidateLinkEstimationMethod', 'hough', 'WeightMethod', 'max', ...
    'OverwriteFile', false, 'FragmentLocation', feature.DataPoint(0,'second'), ...
    'FragmentDuration', feature.DataPoint(15, 'second')};

%% start repetitive section linking
disp(' ');disp('------------ Tonic Identification Wrapper -----------')

%% get the file locations
fileLocations = fragmentLinker.FileOperation.getAudioScorePairs(...
    dataFolder, 'wav', 'txt', ignoreFolders);
temp = cellfun(@(x) fullfile(fileparts(x),'predominantMelody.mat'),...
    {fileLocations.audio}, 'unif', false);
[fileLocations.predominantMelody] = temp{:}; clear temp

%% instantiate the estimator objects
tonicIdentifier = makamLinker.TonicIdentifier(options);
identifyTonic = @(score, audio, predominantMelody) ...
    tonicIdentifier.identify(score, audio, predominantMelody);

% you can do parfor if you have parallel processing toolbox
% just uncomment the parpool block in the start and end of the script
% and replace the "for" with "parfor"
tonicEstimated =  cell(size(fileLocations));
info = cell(size(fileLocations));
for k = 1:length(fileLocations)
    %% print the experiment
    [~, audioname] = fileparts(fileLocations(k).audio);
    disp([num2str(k) ': ' audioname])
    
    % tonic identification
    [tonicEstimated{k}, info{k}] = identifyTonic(fileLocations(k).score,...
        fileLocations(k).audio, fileLocations(k).predominantMelody);
end
tonicEstimated = [tonicEstimated{:}];

%% Evaluation
disp('> Evaluate Links')

tonicFilenames = arrayfun(@(x) fullfile(fileparts(x.audio),'tonic.json'),...
    fileLocations, 'unif', false);
[results, stat] = fragmentLinker.Evaluator.evaluateTonicEstimations(...
    tonicEstimated, tonicFilenames, true, {fileLocations.audio});

disp(['Identified ' num2str(results.numSuccess) '/' ...
    num2str(length(fileLocations)) ' audio recordings.'])
disp(['Success rate: ' num2str(results.successRate, '%.1f') '%'])
disp(['Tonic Identification took ' num2str(toc(wrapperStart)) ...
    ' seconds.'])

%% close parpool
fragmentLinker.buzz
delete(gcp('nocreate'))
