

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

paths = paths();  

subj = 'vp04';
roi_name = 'right_FFA';  
spm_name = 'SPM.mat';

spm_file = fullfile(paths.participants, subj, '00_loc', 'spm', spm_name);
roi_file = fullfile(paths.participants, subj, '06_roi', sprintf('%s_roi.mat', roi_name));

D  = mardo(spm_file);
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

nTP = 6

% Options - here 'single' FIR model, return estimated % signal change
opts = struct('single', 1, 'percent', 1);

% Return time courses for all events in fir_tc matrix
for e_s = 1:n_events
  fir_tc(:, e_s) = event_fitted(E, e_specs(:,e_s), nTP);
end
save subject_1_rFFA_fir.txt fir_tc -ASCII
save subject_1_rFFA_pc.txt pct_ev -ASCII -TABS
figure
plot(fir_tc);
legend(e_names)
