%% TODO: Script for Localizer extraction

%% Init paths
clear
paths = paths();  

subj = 'vp03';
roi_name = 'right_FFA';  
spm_name = 'SPM.mat';

spm_file = fullfile(paths.participants, subj, '05_total', spm_name);
roi_file = fullfile(paths.participants, subj, '06_roi', sprintf('%s_roi.mat', roi_name));

%% Specify ROI, Design and Estimate
D = mardo(spm_file);
R = maroi(roi_file);
Y = get_marsy(R, D, 'mean');

E = estimate(D, Y);

%% Specify relevant conditions
fixedConditions = {'coherent', 'incoherent_real', 'incoherent_mock', 'neutral'}
[eSpecs, eNames] = event_specs(E);

% get relevant idx
conditionIdx = false(1,numel(eNames))
for i = 1:numel(fixedConditions)
    conditionIdx = conditionIdx | contains(eNames, fixedConditions{i});
end

% drop "target"
eSpecs = eSpecs(:, conditionIdx);
eNames = eNames(:, conditionIdx);

conditionIdx = struct();

for c = 1:numel(fixedConditions)
    cond = fixedConditions{c};

    % Match condition name as a full token
    pattern = ['(^|_)' cond '(_|$)'];

    conditionIdx.(cond) = find(~cellfun('isempty', ...
        regexp(eNames, pattern)));
end

%% Fit model
nTimePoints = 0.25;
nConds = numel(fixedConditions);

for c = 1:nConds
    thisCond = fixedConditions{c};
    idx = conditionIdx.(thisCond);

    for r = 1:numel(idx)
        tc_allRuns(:,r) = event_fitted(E, eSpecs(:, idx(r)), nTimePoints);
    end

    % Average across runs
    timeCourses(:,c) = mean(tc_allRuns, 2);
end


figure;
plot(timeCourses);
legend(eNames);


