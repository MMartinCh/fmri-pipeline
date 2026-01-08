%% ==================== SPM25 Normalize: Estimate & Write ====================
% Normalizes anatomical image to MNI space (per run)

spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

% Use SPM installation TPM automatically
tpm_path = fullfile(spm('Dir'), 'tpm', 'TPM.nii');

for r = 1:numel(runs)
    run_id = runs{r};

    anat_dir = fullfile(base_dir, subj, run_id, 'anat');

    %% --- Find anatomical image ---
    anat_img = dir(fullfile(anat_dir, '*.nii'));
    if isempty(anat_img)
        warning('No anatomical image found for %s - %s', subj, run_id);
        continue;
    end
    anat_img = fullfile(anat_img(1).folder, anat_img(1).name);

    %% --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = { ...
        [anat_img ',1'] };
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = { ...
        [anat_img ',1'] };

    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {tpm_path};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = ...
        [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;

    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = ...
        [-78 -112 -70
          78   76   85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 2;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

    %% --- Run ---
    spm_jobman('run', matlabbatch);

    %% --- Report ---
    [folder, name, ext] = fileparts(anat_img);
    warped_anat = fullfile(folder, ['w' name ext]);

    if exist(warped_anat, 'file')
        fprintf('✔ Normalized anatomical written: %s\n', warped_anat);
    else
        fprintf('✘ Normalized anatomical NOT found: %s\n', warped_anat);
    end

    fprintf('Normalization completed: %s - %s\n\n', subj, run_id);
end

fprintf('All normalization runs finished for subject: %s\n', subj);
