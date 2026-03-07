%% === SPM25: Combined First-Level Model ===

full_analysis_dir = char(fullfile(paths.participants, subj, '05_total', "face_split"));
if ~exist(full_analysis_dir, 'dir')
    mkdir(full_analysis_dir);
end

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = {full_analysis_dir};

matlabbatch{1}.spm.stats.fmri_spec.timing.units   = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

sess_idx = 0;

for r = 1:numel(runs)
    run_id = runs{r};

    % --- Skip Localizer
    if startsWith(run_id, '00_loc')
        fprintf('Skipping localizer run: %s\n', run_id);
        continue;
    end

    % === Run for standard functional only
    sess_idx = sess_idx + 1;
    func_dir = fullfile(paths.participants, subj, run_id, 'func');

    % --- Get Functional Files
    func_files = dir(fullfile(func_dir, 'swaf*.nii'));
    func_files = fullfile({func_files.folder}, {func_files.name})';

    if isempty(func_files)
        error('No functional files found for %s - %s', subj, run_id);
    end
    fprintf('Session %d: %d scans found (%s)\n', sess_idx, numel(func_files), run_id);

    % --- Get MCF
    mcf_file = fullfile(paths.participants, subj, run_id, 'mcf', 'MCF_face_split.mat');
    if ~exist(mcf_file, 'file')
        error('Missing MCF.mat for %s - %s', subj, run_id);
    end

    %--- Get Motion Regressors
    rp_file = dir(fullfile(func_dir, 'rp_*.txt'));
    if isempty(rp_file)
        error('Missing motion regressors for %s - %s', subj, run_id);
    end
    rp_file_path = fullfile(rp_file.folder, rp_file.name);

    % --- Specify Session
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).scans = func_files;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).cond  = ...
        struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).multi = {mcf_file};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).regress = ...
        struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).multi_reg = {rp_file_path};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess_idx).hpf = 128;
end

if sess_idx == 0
    warning('No functional runs found – combined model not created.');
    return;
end

% === Global Model Parameters
matlabbatch{1}.spm.stats.fmri_spec.fact            = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt            = 1;
matlabbatch{1}.spm.stats.fmri_spec.global          = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh         = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask            = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi             = 'AR(1)';

spm_jobman('run', matlabbatch);

fprintf('\nCombined first-level model created for subject: %s\n', subj);
fprintf('Functional sessions: %d\n', sess_idx);
fprintf('Output: %s\n', full_analysis_dir);
