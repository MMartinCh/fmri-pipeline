%% ==================== Master Pipeline ====================
% === Settings ===
spm('defaults', 'FMRI');
spm_jobman('initcfg');

paths = paths();

subjects = {'vp09_MH'};
runs = {'01_func', '02_func', '03_func', '04_func'};

options = ['spec'];

% === Main ===
for s = 1:numel(subjects)
    subj = subjects{s};
    fprintf('\n==============================\n');
    fprintf('Starting preprocessing for subject: %s\n', subj);

    % --- Preprocessing
    if ismember('pre', options)
        run('step_00_dcm_import_anat.m');
        run('step_01_dcm_import_func.m');
        run('step_02_slice_timing.m');
        run('step_03_realignment.m');
        run('step_04_coreg.m');
        run('step_05_normalize_1.m');
        run('step_06_normalize_2.m');
        run('step_07_smoothing.m');
    else 
        fprintf('Skipping Preprocessing...\n');
    end

    % --- First-Level-Analysis
    if ismember('spec', options)
        run('step_08_localizer_specification.m');
        run('step_09_whole_run_specification.m');
        run('step_10_model_estimation.m');
    else
        fprintf('Skipping First-Level-Analysis...\n');
    end

    fprintf('Batch finished for %s\n', subj);

end

beep;
fprintf('\nALL PROCESSING FINISHED.\n');
