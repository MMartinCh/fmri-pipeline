clear

%% Specify session
paths = paths();  
roiName = 'right_OFA';
coordTable = readtable('roi_coordinates.xlsx');

customSubjects = {};

%% Decide custom or full processing
if ~isempty(customSubjects)
    subjects = customSubjects;
    fprintf('Custom processing. \n');
else 
    vpDirs = dir(fullfile(paths.participants, 'vp*'));
    vpDirs = vpDirs([vpDirs.isdir]);
    subjects = {vpDirs.name};
    fprintf('Full processing for all subjects. \n')
end

%% ROI extraction for every participant
for s = 1:numel(subjects)

    subject = subjects{s};
    fprintf('Subject: %s', subject);

    %% Find SPM and ROI
    spmName = fullfile(paths.participants, subject, '05_total', 'face_split','SPM.mat'); 
    roiFile = fullfile(paths.participants, subject, '06_roi', sprintf('%s_roi.mat', roiName));

    % Create ROI sphere from coordinates 
    rowIdx = strcmp(coordTable.path, subject);
    coordStr = coordTable{rowIdx, roiName};
    coordStr = char(coordStr);
        
    center = sscanf(coordStr, '%f %f %f')';
    radius = 4;

    roi = maroi_sphere(struct('centre', center, 'radius', radius));
    roi = label(roi, roiName);
    saveroi(roi, roiFile)

    if ~exist(spmName, 'file') || ~exist(roiFile, 'file')
        fprintf('%s skipped: missing SPM.mat or ROI file \n', subject);
        continue
    end

    % Specify ROI, Design and Estimate
    D  = mardo(spmName);
    R  = maroi(roiFile);
    Y  = get_marsy(R, D, 'mean');  

    E = estimate(D, Y);

    % Specify conditions
    fixedConditions = {'Congruent', 'Incongruent_Real', 'Incongruent_Fake', 'Neutral_Real', 'Neutral_Fake'};

    conditionMap.Congruent = {'Congruent'};
    conditionMap.Incongruent_Real = {'Incongruent_Real'};
    conditionMap.Incongruent_Fake = {'Incongruent_Fake'};
    conditionMap.Neutral_Real = {'Neutral_Real'};
    conditionMap.Neutral_Fake = {'Neutral_Fake'};
    
    [eSpecs, eNames] = event_specs(E);
    
    conditionIdx = struct();
    
    for c = 1:numel(fixedConditions)
        thisCond = fixedConditions{c};
        pattern = ['(^|_)' thisCond '(_|$)'];
        conditionIdx.(thisCond) = find(~cellfun('isempty', regexp(eNames, pattern)));
    end

    % Define timing parameters
    firLength = 24;
    binSize = tr(E);
    binNumber = firLength / binSize;

    opts = struct('single', 1, 'percent', 1);

    % Fit model
    for c = 1:numel(fixedConditions)
        fir_allRuns = [];

        thisCond = fixedConditions{c};
        idx = conditionIdx.(thisCond);
    
        for r = 1:numel(idx)
            fir_allRuns(:,r) = event_fitted_fir(E, eSpecs(:, idx(r)), binSize, binNumber, opts);
        end
    
        % Average across runs
        fir_tc(:,c) = mean(fir_allRuns, 2);
    end

    %% Plot FIR
    figure;
    plot(fir_tc);
    legend(fixedConditions)
    title(sprintf('%s - %s FIR', subject, roiName));

    %% Safe outputs
    roiOutFolder = fullfile(paths.roiAnalysis, roiName, 'face_split');
    plotFolder   = fullfile(roiOutFolder, 'plots');
    
    if ~exist(roiOutFolder, 'dir')
        mkdir(roiOutFolder);
    end
    
    if ~exist(plotFolder, 'dir')
        mkdir(plotFolder);
    end

    fir_file = fullfile(roiOutFolder, sprintf('%s_%s_fir_FS.txt', subject, roiName));
    fig_file = fullfile(plotFolder, sprintf('%s_%s_fir_FS.png', subject, roiName));

    save(fir_file, 'fir_tc', '-ASCII');
    saveas(gcf, fig_file);

    close(gcf);

end

fprintf('ROI ANALYSIS FINISHED')
beep;