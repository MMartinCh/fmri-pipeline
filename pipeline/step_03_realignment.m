%% ==================== SPM25 Realignment (Est & Write) ====================
spm('defaults','FMRI');
spm_jobman('initcfg');

runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';
prefix = 'r'; % realign prefix

for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(base_dir, subj, run_id, 'func');
    
    % --- Find all slice-timed files ---
    st_files = dir(fullfile(func_dir, 's*.nii'));
    if isempty(st_files)
        warning('No slice-timed files found for %s - %s', subj, run_id);
        continue;
    end
    st_files = fullfile({st_files.folder}, {st_files.name})'; % column cell
    
    % --- Build matlabbatch ---
    clear matlabbatch
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {st_files}; % <- correct nesting
    
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = prefix;
    
    % --- Run the batch ---
    spm_jobman('run', matlabbatch);
    
    % --- Print realigned files ---
    for i = 1:numel(st_files)
        [folder, name, ext] = fileparts(st_files{i});
        realigned_file = fullfile(folder, [prefix name ext]);
        fprintf('Realigned file created: %s\n', realigned_file);
    end
    
    fprintf('Realignment completed for %s - %s\n', subj, run_id);
end

fprintf('All realignment runs finished for subject: %s\n', subj);