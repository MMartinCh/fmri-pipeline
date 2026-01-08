%% ==================== SPM25 Smoothing ====================
% Fully automated smoothing for all runs of a subject

% --- Setup SPM ---
spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';
fwhm = [8 8 8];   % smoothing kernel
prefix = 's';      % smoothed files prefix

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(base_dir, subj, run_id, 'func');  % folder with normalized functional files
    
    % --- Find all normalized functional files (nrs*.nii) ---
    norm_files = dir(fullfile(func_dir, 'nrs*.nii'));
    if isempty(norm_files)
        warning('No normalized functional files found for %s - %s', subj, run_id);
        continue;
    end
    norm_files = fullfile({norm_files.folder}, {norm_files.name})';  % column cell array
    
    % --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.spatial.smooth.data = norm_files;
    matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm;
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = prefix;
    
    % --- Run the batch ---
    spm_jobman('run', matlabbatch);
    
    % --- Print smoothed files ---
    for i = 1:numel(norm_files)
        [folder, name, ext] = fileparts(norm_files{i});
        smoothed_file = fullfile(folder, [prefix name ext]);
        fprintf('Smoothed file created: %s\n', smoothed_file);
    end
    
    fprintf('Smoothing completed for %s - %s\n', subj, run_id);
end

fprintf('All smoothing runs finished for subject: %s\n', subj);
