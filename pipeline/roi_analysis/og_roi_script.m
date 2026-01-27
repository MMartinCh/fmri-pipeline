

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm_name = 'C:\MarsBar_Einführung\Subject_1\functional\stat\SPM.mat'
roi_file = 'C:\MarsBar_Einführung\Subject_1\ROIs\1_rFFA_roi.mat'
% Make marsbar design object
D  = mardo(spm_name);
% Make marsbar ROI object
R  = maroi(roi_file);
% Fetch data into marsbar data object                           Y = getdata(R, images(D));
Y  = get_marsy(R, D, 'mean');

% Get contrasts from original design
xCon = get_contrasts(D);
% Estimate design on ROI data TAKES LONG!!!
tic
E = estimate(D, Y);
toc

% Get definitions of all events in model
[e_specs, e_names] = event_specs(E);
n_events = size(e_specs, 2);
dur = 0;

% Return percent signal esimate for all events in design
for e_s = 1:n_events
  pct_ev(e_s) = event_signal(E, e_specs(:,e_s), dur);
end

e_names
pct_ev

% Length of FIR in seconds
fir_length = 24;
% Bin size in seconds for FIR
bin_size = tr(E);
% Number of FIR time bins to cover length of FIR
bin_no = fir_length / bin_size;

% Options - here 'single' FIR model, return estimated % signal change
opts = struct('single', 1, 'percent', 1);

% Return time courses for all events in fir_tc matrix
for e_s = 1:n_events
  fir_tc(:, e_s) = event_fitted_fir(E, e_specs(:,e_s), bin_size, ...
				    bin_no, opts);
end
save subject_1_rFFA_fir.txt fir_tc -ASCII
save subject_1_rFFA_pc.txt pct_ev -ASCII -TABS
figure
plot(fir_tc);

