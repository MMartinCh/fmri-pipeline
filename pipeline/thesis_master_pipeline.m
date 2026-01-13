%% ==================== Master Pipeline ====================
% === Init ===
spm('defaults', 'FMRI');
spm_jobman('initcfg');

subjects = {'vp07'};    
runs = {'01_func','02_func','03_func','04_func'};

paths = paths();

% === Main ===
for s = 1:numel(subjects)
    subj = subjects{s};
    fprintf('\n==============================\n');
    fprintf('Starting preprocessing for subject: %s\n', subj);
    
    run('step_00_dcm_import_anat.m');
    run('step_01_dcm_import_func.m');
    run('step_02_slice_timing.m');
    run('step_03_realignment.m');
    run('step_04_coreg.m');
    run('step_05_normalize_1.m');
    run('step_06_normalize_2.m');
    run('step_07_smoothing.m');
    run('step_08_model_specification.m')
    run('step_09_whole_run_specification.m')
    run('step_10_model_estimation.m')
    
    fprintf('Finished preprocessing for subject: %s\n', subj);
    fprintf('==============================\n\n');
end

fprintf('All preprocessing finished.\n');
