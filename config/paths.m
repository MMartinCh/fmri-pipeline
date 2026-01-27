function paths = paths()

    paths.root = fileparts(fileparts(mfilename('fullpath')));

    paths.participants = fullfile(paths.root, 'analysis', 'participants');
    
    paths.roiAnalysis = fullfile(paths.root, 'analysis', 'roi_analysis');

    paths.raw_anat_ext = 'raw\raw_anat';

    paths.tpm = fullfile(spm('Dir'), 'tpm', 'TPM.nii')

end