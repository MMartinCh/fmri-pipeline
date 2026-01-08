%% ==================== SPM25 DICOM Import Pipeline ====================
% Fully automated import for multiple subjects and runs

% --- Setup SPM ---
spm('defaults', 'FMRI');
spm_jobman('initcfg');

%% --- Define runs ---
runs = {'01_func','02_func','03_func','04_func'};  % Add all functional run folders
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

%% --- Loop over subjects and runs ---
for s = 1:numel(subjects)
    subj = subjects{s};
    
    for r = 1:numel(runs)
        run_id = runs{r};
        
        % --- Construct folder paths ---
        raw_dir = fullfile(base_dir, subj, 'raw', '00_anat_raw');  
        out_dir = fullfile(base_dir, subj, run_id, 'anat');         % e.g., 01_func/func
        
        % --- Make sure output folder exists ---
        if ~exist(out_dir, 'dir')
            mkdir(out_dir);
        end
        
        % --- List all DICOM files in raw folder ---
        dcm_files = dir(fullfile(raw_dir, '*.dcm'));
        if isempty(dcm_files)
            warning('No DICOM files found for %s - %s', subj, run_id);
            continue;
        end
        dcm_files = fullfile({dcm_files.folder}, {dcm_files.name})';
        
        % --- Create batch for DICOM import ---
        clear matlabbatch
        matlabbatch{1}.spm.util.import.dicom.data = dcm_files;
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = {out_dir};
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        
        % --- Run the batch ---
        spm_jobman('run', matlabbatch);
        
        fprintf('DICOM import completed: Subject %s, Run %s\n', subj, run_id);
    end
end

fprintf('All DICOM imports finished.\n');
