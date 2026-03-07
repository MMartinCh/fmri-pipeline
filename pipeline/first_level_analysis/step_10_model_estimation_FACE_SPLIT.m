%% === SPM25: Model Estimation per Run ===

% === Localizer ===
localizer_spm_dir = fullfile(paths.participants, subj, '00_loc', 'spm');
localizer_spm_mat = fullfile(localizer_spm_dir, 'SPM.mat');

if ismember('00_loc', runs)
    if ~exist(localizer_spm_mat, 'file')
        warning('No localizer SPM.mat found for subject %s. Skipping total model estimation.', subj);
    else
        fprintf('\nEstimating Localizer model for subject: %s\n', subj);
        fprintf('Using: %s\n', localizer_spm_mat);
    
        clear matlabbatch
        matlabbatch{1}.spm.stats.fmri_est.spmmat = {localizer_spm_mat};
        matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
    
        spm_jobman('run', matlabbatch);
    
        fprintf('Localizer model estimation completed for subject: %s\n', subj);
    end
end

% === Total ===
if ismember('01_func', runs)
    
    total_spm_dir = fullfile(paths.participants, subj, '05_total', 'face_split');
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
end