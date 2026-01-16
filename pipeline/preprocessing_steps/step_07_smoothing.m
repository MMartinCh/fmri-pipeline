%% === SPM25 Smoothing ===

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(paths.participants, subj, run_id, 'func');  
    
    norm_files = dir(fullfile(func_dir, 'waf*.nii'));
    if isempty(norm_files)
        warning('No normalized functional files found for %s - %s', subj, run_id);
        continue;
    end
    norm_files = fullfile({norm_files.folder}, {norm_files.name})'; 
    

    clear matlabbatch
    matlabbatch{1}.spm.spatial.smooth.data = norm_files;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    
    spm_jobman('run', matlabbatch);    
    fprintf('Smoothing completed for %s - %s\n', subj, run_id);
end

fprintf('All smoothing runs finished for subject: %s\n', subj);
