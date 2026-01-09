%% === SPM25: Model Estimation per Run ===

% --- Setup SPM ---
spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

for r = 1:numel(runs)
    run_id = runs{r};
    spm_dir = fullfile(base_dir, subj, run_id, 'spm');
    spm_mat = fullfile(spm_dir, 'SPM.mat');

    % --- Check SPM.mat ---
    if ~exist(spm_mat, 'file')
        warning('No SPM.mat found for %s - %s. Skipping.', subj, run_id);
        continue;
    end

    fprintf('\n Estimating model for %s - %s\n', subj, run_id);
    fprintf('Using: %s\n', spm_mat);

    % --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {spm_mat};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    % --- Run estimation ---
    spm_jobman('run', matlabbatch);

    fprintf('Model estimation completed: %s - %s\n', subj, run_id);
end

fprintf('\nAll first-level model estimations finished for subject: %s\n', subj);
