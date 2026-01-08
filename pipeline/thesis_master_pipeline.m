%% ==================== Master Pipeline ====================
% Specify subjects 
subjects = {'vpTEST'};

% Base directory for all subjects
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

% Loop over subjects and call step scripts
for s = 1:numel(subjects)
    subj = subjects{s};
    fprintf('\n==============================\n');
    fprintf('Starting preprocessing for subject: %s\n', subj);
    
    % DICOM import anatomical scan
    % run('step_00_dcm_import_anat.m');

    % DICOM import functional scans
    % run('step_01_dcm_import_func.m');
    
    % Slice timing
    % run('step_02_slice_timing.m');
    
    % Realignment
    % run('step_03_realignment.m');
    
    % Coregistration
    run('step_04_coreg.m');
    
    % Normalization
    % run('step_05_normalize_all.m');
    
    % Smoothing
    % run('step_06_smooth_all.m');
    
    fprintf('Finished preprocessing for subject: %s\n', subj);
    fprintf('==============================\n\n');
end

fprintf('All preprocessing finished.\n');
