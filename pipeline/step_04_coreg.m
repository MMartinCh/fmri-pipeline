%% ==================== SPM25 Coregister: Estimate ====================
% Coregisters anatomical image to mean functional (per run)

spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

for r = 1:numel(runs)
    run_id = runs{r};

    func_dir = fullfile(base_dir, subj, run_id, 'func');
    anat_dir = fullfile(base_dir, subj, run_id, 'anat');

    %% --- Find mean functional image ---
    mean_func = dir(fullfile(func_dir, 'mean*.nii'));
    if isempty(mean_func)
        warning('No mean functional found for %s - %s', subj, run_id);
        continue;
    end
    mean_func = fullfile(mean_func(1).folder, mean_func(1).name);

    %% --- Find anatomical image ---
    anat_img = dir(fullfile(anat_dir, '*.nii'));
    if isempty(anat_img)
        warning('No anatomical image found for %s - %s', subj, run_id);
        continue;
    end
    anat_img = fullfile(anat_img(1).folder, anat_img(1).name);

    %% --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = { [mean_func ',1'] };
    matlabbatch{1}.spm.spatial.coreg.estimate.source = { [anat_img ',1'] };
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};

    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = ...
        [0.02 0.02 0.02 ...
         0.001 0.001 0.001 ...
         0.01 0.01 0.01 ...
         0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    %% --- Run ---
    spm_jobman('run', matlabbatch);

    fprintf('Coregistration completed: %s - %s\n', subj, run_id);
    fprintf('  Ref:    %s\n', mean_func);
    fprintf('  Source: %s\n\n', anat_img);
end

fprintf('All coregistration runs finished for subject: %s\n', subj);
