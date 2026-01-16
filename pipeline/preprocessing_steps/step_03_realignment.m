%% === SPM25 Realignment (Est & Write) ===

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(paths.participants, subj, run_id, 'func');
    

    st_files = dir(fullfile(func_dir, 'af*.nii'));
    if isempty(st_files)
        warning('No slice-timed files found for %s - %s', subj, run_id);
        continue;
    end
    st_files = fullfile({st_files.folder}, {st_files.name})';
    

    clear matlabbatch
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {st_files};
    
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = '';
    

    spm_jobman('run', matlabbatch);
    
    fprintf('Realignment completed for %s - %s\n', subj, run_id);
end

fprintf('All realignment runs finished for subject: %s\n', subj);