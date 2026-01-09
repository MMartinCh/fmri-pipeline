%% === Slice Timing correction ===
spm('defaults','FMRI'); 
spm_jobman('initcfg');

% --- Runs and base folder ---
runs = {'01_func','02_func','03_func','04_func'};
base_dir = 'C:\Users\Martin\Desktop\Uni\Masterarbeit\Masterarbeit_Datenanalyse\probanden';

nslices = 84; 
tr = 1;
ta = tr - tr/nslices;
so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 65 67 69 71 73 75 77 79 81 83 ...
      2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84];
refslice = 83;
prefix = 'af';

% --- Loop over runs ---
for r = 1:numel(runs)
    run_id = runs{r};
    func_dir = fullfile(base_dir, subj, run_id, 'func');  % folder with imported NIfTIs
    
    nii_files = dir(fullfile(func_dir, 'MF*.nii')); % regex, MF prefix
    if isempty(nii_files)
        warning('No NIfTI files found for %s - %s', subj, run_id);
        continue;
    end
    nii_files = fullfile({nii_files.folder}, {nii_files.name})';
    
    clear matlabbatch
    matlabbatch{1}.spm.temporal.st.scans = {nii_files};
    matlabbatch{1}.spm.temporal.st.nslices = nslices;
    matlabbatch{1}.spm.temporal.st.tr = tr;
    matlabbatch{1}.spm.temporal.st.ta = ta;
    matlabbatch{1}.spm.temporal.st.so = so;
    matlabbatch{1}.spm.temporal.st.refslice = refslice;
    matlabbatch{1}.spm.temporal.st.prefix = prefix;
    
    spm_jobman('run', matlabbatch);
    
    fprintf('Slice timing done: %s - %s\n', subj, run_id);
end
