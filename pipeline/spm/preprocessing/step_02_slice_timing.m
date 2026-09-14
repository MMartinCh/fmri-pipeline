%% === Slice Timing correction ===

for r = 1:numel(runs)
    run_id = runs{r};

    func_dir = fullfile(paths.participants, subj, run_id, 'func');

    nii_files = dir(fullfile(func_dir, 'MF*.nii'));
    if isempty(nii_files)
        warning('No NIfTI files found for %s - %s', subj, run_id);
        continue;
    end
    nii_files = fullfile({nii_files.folder}, {nii_files.name})';

    clear matlabbatch
    matlabbatch{1}.spm.temporal.st.scans = {nii_files};

    if startsWith(run_id, '00_loc')
        % --- Localizer Batch
        matlabbatch{1}.spm.temporal.st.nslices = 100;
        matlabbatch{1}.spm.temporal.st.tr = 2;
        matlabbatch{1}.spm.temporal.st.ta = 2 - 2/100;
        matlabbatch{1}.spm.temporal.st.so = ...
            [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 ...
             51 53 55 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 ...
             2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 ...
             52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 100];
        matlabbatch{1}.spm.temporal.st.refslice = 99;
        matlabbatch{1}.spm.temporal.st.prefix = 'af';

    else
        % --- Functional batch
        matlabbatch{1}.spm.temporal.st.nslices = 84;
        matlabbatch{1}.spm.temporal.st.tr = 1;
        matlabbatch{1}.spm.temporal.st.ta = 1 - 1/84;
        matlabbatch{1}.spm.temporal.st.so = ...
            [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 65 67 69 71 73 75 77 79 81 83 ...
             2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84];
        matlabbatch{1}.spm.temporal.st.refslice = 83;
        matlabbatch{1}.spm.temporal.st.prefix = 'af';
    end


    spm_jobman('run', matlabbatch);

    fprintf('Slice timing done: %s - %s\n', subj, run_id);
end
