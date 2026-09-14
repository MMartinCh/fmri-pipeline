%% ==================== SPM25 DICOM Import Pipeline ====================

for r = 1:numel(runs)
    run_id = runs{r};

    raw_dir = fullfile(paths.participants, subj, paths.raw_anat_ext);  
    out_dir = fullfile(paths.participants, subj, run_id, 'anat');
        
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
        
    dcm_files = dir(fullfile(raw_dir, '*.dcm'));
    if isempty(dcm_files)
        warning('No DICOM files found for %s - %s', subj, run_id);
        continue;
    end
    dcm_files = fullfile({dcm_files.folder}, {dcm_files.name})';
        
    clear matlabbatch
    matlabbatch{1}.spm.util.import.dicom.data = dcm_files;
    matlabbatch{1}.spm.util.import.dicom.root = 'flat';
    matlabbatch{1}.spm.util.import.dicom.outdir = {out_dir};
    matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
    matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
    matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
    matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

    spm_jobman('run', matlabbatch);
        
    fprintf('DICOM import completed: Subject %s, Run %s\n', subj, run_id);
end

fprintf('All DICOM imports finished.\n');
