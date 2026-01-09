%% === SPM25: Model Specification per Run ===
% Fully automated first-level GLM model specification for each run separately

% --- Setup SPM ---
spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';             

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(base_dir, subj, run_id, 'func');

    % --- Functional images (smoothed normalized) ---
    func_files = dir(fullfile(func_dir, 'swaf*.nii'));
    func_files = fullfile({func_files.folder}, {func_files.name})';
    if isempty(func_files)
        warning('No functional files found for %s - %s', subj, run_id);
        continue;
    end
    fprintf('Found %d functional files for %s - %s\n', numel(func_files), subj, run_id);

    % --- Multi-condition file ---
    multi_file = fullfile(base_dir, subj, run_id, 'mcf', 'MCF.mat');
    if ~exist(multi_file, 'file')
        warning('No MCF file found for %s - %s', subj, run_id);
    else
        fprintf('MCF file found for %s - %s: %s\n', subj, run_id, multi_file);
    end

    % --- Motion regressors ---
    rp_file = dir(fullfile(func_dir, 'rp_*.txt'));
    if isempty(rp_file)
        warning('No motion regressor found for %s - %s', subj, run_id);
        rp_file_path = {};
    else
        rp_file_path = fullfile(rp_file.folder, rp_file.name);
        fprintf('Motion regressor found for %s - %s: %s\n', subj, run_id, rp_file_path);
    end

    % --- SPM folder for this run ---
    spm_dir = fullfile(base_dir, subj, run_id, 'spm');
    if ~exist(spm_dir, 'dir')
        mkdir(spm_dir);
    end

    % --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = func_files;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {multi_file};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = rp_file_path;
    % matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''}; % debug
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    % matlabbatch{1}.spm.stats.fmri_spec.cvi = 'None'; % debug


    % --- Run the batch for this run ---
    spm_jobman('run', matlabbatch);
    fprintf('Model specification completed for subject: %s - run: %s\n', subj, run_id);
end

fprintf('All first-level models created separately for subject: %s\n', subj);
