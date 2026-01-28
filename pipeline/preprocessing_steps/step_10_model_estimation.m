%% === SPM25: Model Estimation per Run ===

% === Total ===
total_spm_dir = fullfile(paths.participants, subj, '00_loc', 'spm');
total_spm_mat = fullfile(total_spm_dir, 'SPM.mat');

if ~exist(total_spm_mat, 'file')
    warning('No total SPM.mat found for subject %s. Skipping total model estimation.', subj);
else
    fprintf('\nEstimating TOTAL model for subject: %s\n', subj);
    fprintf('Using: %s\n', total_spm_mat);

    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {total_spm_mat};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    spm_jobman('run', matlabbatch);

    fprintf('Total first-level model estimation completed for subject: %s\n', subj);
end
