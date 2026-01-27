%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paths = paths();  
roi_name = 'right_FFA';  

vp_dirs = dir(fullfile(paths.participants, 'vp*'));
vp_dirs = vp_dirs([vp_dirs.isdir]);

for s = 1:length(vp_dirs)

    subject = vp_dirs(s).name;
    fprintf('Subject: %s', subject);


    spm_name = fullfile(paths.participants, subject, '05_total', 'SPM.mat'); 
    roi_file = fullfile(paths.participants, subject, '06_roi', sprintf('%s_roi.mat', roi_name));

    D  = mardo(spm_name);
    R  = maroi(roi_file);
    Y  = get_marsy(R, D, 'mean');  

    xCon = get_contrasts(D);

    tic
    E = estimate(D, Y);
    toc

    [e_specs, e_names] = event_specs(E);
    n_events = size(e_specs, 2);
    dur = 0;

    clear pct_ev
    for e_s = 1:n_events
        pct_ev(e_s) = event_signal(E, e_specs(:,e_s), dur);
    end

    fir_length = 24;
    bin_size = tr(E);
    bin_no = fir_length / bin_size;

    opts = struct('single', 1, 'percent', 1);

    clear fir_tc
    for e_s = 1:n_events
        fir_tc(:, e_s) = event_fitted_fir(E, e_specs(:,e_s), ...
                                          bin_size, bin_no, opts);
    end

    %% Safe outputs
    fir_file = fullfile(paths.roiAnalysis, ...
        sprintf('%s_%s_fir.txt', subject, roi_name));

    pc_file = fullfile(paths.roiAnalysis, ...
        sprintf('%s_%s_pc.txt', subject, roi_name));

    save(fir_file, 'fir_tc', '-ASCII');
    save(pc_file, 'pct_ev', '-ASCII', '-TABS');

    figure;
    plot(fir_tc);
    title(sprintf('%s - %s FIR', subject, roi_name));

end
