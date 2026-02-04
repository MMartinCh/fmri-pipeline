clear

%% Get participants paths
paths = paths();  
roiName = 'right_FFA';  

vpDirs = dir(fullfile(paths.participants, 'vp*'));
vpDirs = vpDirs([vpDirs.isdir]);

%% ROI extraction for every participant
for s = 1:length(vpDirs)

    subject = vpDirs(s).name;
    fprintf('Subject: %s', subject);

    % Find SPM and ROI
    spmName = fullfile(paths.participants, subject, '05_total', 'SPM.mat'); 
    roiFile = fullfile(paths.participants, subject, '06_roi', sprintf('%s_roi.mat', roiName));

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
    fixedConditions = {'coherent', 'incoherent', 'neutral'};

    conditionMap.coherent   = {'coherent'};
    conditionMap.incoherent = {'incoherent_real', 'incoherent_mock'};
    conditionMap.neutral    = {'neutral'};
    
    [eSpecs, eNames] = event_specs(E);
    
    conditionIdx = struct();
    
    for c = 1:numel(fixedConditions)
        thisCond = fixedConditions{c};
        subConds = conditionMap.(thisCond);
    
        idx = [];
        for sc = 1:numel(subConds)
            pattern = ['(^|_)' subConds{sc} '(_|$)'];
            idx = [idx find(~cellfun('isempty', regexp(eNames, pattern)))];
        end
    
        conditionIdx.(thisCond) = idx;
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

    %% Safe outputs
    fir_file = fullfile(paths.roiAnalysis, roiName, sprintf('%s_%s_fir.txt', subject, roiName));
    save(fir_file, 'fir_tc', '-ASCII');

    figure;
    plot(fir_tc);
    legend(fixedConditions)
    title(sprintf('%s - %s FIR', subject, roiName));

end
