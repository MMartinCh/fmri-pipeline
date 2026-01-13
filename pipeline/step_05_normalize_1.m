%% === SPM25 Normalize: Estimate & Write ===

for r = 1:numel(runs)
    run_id = runs{r};

    anat_dir = fullfile(paths.participants, subj, run_id, 'anat');

    anat_img = dir(fullfile(anat_dir, '*.nii'));
    if isempty(anat_img)
        warning('No anatomical image found for %s - %s', subj, run_id);
        continue;
    end
    anat_img = fullfile(anat_img(1).folder, anat_img(1).name);


    clear matlabbatch
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = { ...
        [anat_img ',1'] };
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = { ...
        [anat_img ',1'] };

    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {paths.tpm};
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

    spm_jobman('run', matlabbatch);

    fprintf('Normalization completed: %s - %s\n\n', subj, run_id);
end

fprintf('All normalization runs finished for subject: %s\n', subj);
