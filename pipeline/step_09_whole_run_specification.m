%% === SPM25: Combined First-Level Model (4 runs → 1 SPM.mat) ===

full_analysis_dir = fullfile(paths.participants, subj, '05_total');
if ~exist(full_analysis_dir, 'dir')
    mkdir(full_analysis_dir);
end

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = {full_analysis_dir};

matlabbatch{1}.spm.stats.fmri_spec.timing.units  = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT     = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;


for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(paths.participants, subj, run_id, 'func');

    func_files = dir(fullfile(func_dir, 'swaf*.nii'));
    func_files = fullfile({func_files.folder}, {func_files.name})';

    if isempty(func_files)
        error('No functional files found for %s - %s', subj, run_id);
    end
    fprintf('Session %d: %d scans found (%s)\n', r, numel(func_files), run_id);

  
    mcf_file = fullfile(paths.participants, subj, run_id, 'mcf', 'MCF.mat');
    if ~exist(mcf_file, 'file')
        error('Missing MCF.mat for %s - %s', subj, run_id);
    end

    rp_file = dir(fullfile(func_dir, 'rp_*.txt'));
    if isempty(rp_file)
        error('Missing motion regressors for %s - %s', subj, run_id);
    end
    rp_file_path = fullfile(rp_file.folder, rp_file.name);


    matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = func_files;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond  = ...
        struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {mcf_file};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = ...
        struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = {rp_file_path};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;
end


matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm_jobman('run', matlabbatch);

fprintf('\nCombined first-level model created for subject: %s\n', subj);
fprintf('Sessions: %d\n', numel(runs));
fprintf('Output: %s\n', full_analysis_dir);
