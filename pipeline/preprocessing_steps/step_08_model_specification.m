%% === SPM25: Model Specification per Run ===            

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(paths.participants, subj, run_id, 'func');

    % --- Get functional files
    func_files = dir(fullfile(func_dir, 'swaf*.nii'));
    func_files = fullfile({func_files.folder}, {func_files.name})';
    if isempty(func_files)
        warning('No functional files found for %s - %s', subj, run_id);
        continue;
    end
    fprintf('Found %d functional files for %s - %s\n', numel(func_files), subj, run_id);

    % --- Get MCF
    mcf_file = fullfile(paths.participants, subj, run_id, 'mcf', 'MCF.mat');
    if ~exist(mcf_file, 'file')
        warning('No MCF file found for %s - %s', subj, run_id);
    else
        fprintf('MCF file found for %s - %s: %s\n', subj, run_id, mcf_file);
    end

    % --- Get motion regressors
    rp_file = dir(fullfile(func_dir, 'rp_*.txt'));
    if isempty(rp_file)
        warning('No motion regressor found for %s - %s', subj, run_id);
        rp_file_path = {};
    else
        rp_file_path = fullfile(rp_file.folder, rp_file.name);
        fprintf('Motion regressor found for %s - %s: %s\n', subj, run_id, rp_file_path);
    end

    spm_dir = fullfile(paths.participants, subj, run_id, 'spm');
    if ~exist(spm_dir, 'dir')
        mkdir(spm_dir);
    end

    % === Create and run batch
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';

    if startsWith(run_id, '00_loc')
        % --- Localizer
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    else
        % --- Functional 
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    end

    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans    = func_files;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond     = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi    = {mcf_file};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress  = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {rp_file_path};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf      = 128;

    matlabbatch{1}.spm.stats.fmri_spec.fact           = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt           = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global         = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh        = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask           = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi            = 'AR(1)';

    spm_jobman('run', matlabbatch);
    fprintf('Model specification completed for subject: %s - run: %s\n', subj, run_id);
end

fprintf('All first-level models created separately for subject: %s\n', subj);
