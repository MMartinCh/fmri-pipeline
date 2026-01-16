%% === SPM25 Normalize: Write (Functional) ===

for r = 1:numel(runs)
    run_id = runs{r};

    func_dir = fullfile(paths.participants, subj, run_id, 'func');
    anat_dir = fullfile(paths.participants, subj, run_id, 'anat');


    def_field = dir(fullfile(anat_dir, 'y_*.nii'));
    if isempty(def_field)
        warning('No deformation field found for %s - %s', subj, run_id);
        continue;
    end
    def_field = fullfile(def_field(1).folder, def_field(1).name);

    func_files = dir(fullfile(func_dir, 'af*.nii'));
    if isempty(func_files)
        warning('No realigned functional files found for %s - %s', subj, run_id);
        continue;
    end
    func_files = fullfile({func_files.folder}, {func_files.name})';


    clear matlabbatch
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {def_field};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = func_files;

    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = ...
        [-78 -112 -70
          78   76   85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 2;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

    spm_jobman('run', matlabbatch);
    fprintf('Functional normalization completed: %s - %s\n\n', subj, run_id);
end

fprintf('All functional normalization runs finished for subject: %s\n', subj);
