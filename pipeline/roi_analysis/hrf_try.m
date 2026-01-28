clear

paths = paths();  

subj = 'vp04';
roi_name = 'right_FFA';  
spm_name = 'SPM.mat';

spm_file = fullfile(paths.participants, subj, '00_loc', 'spm', spm_name);
roi_file = fullfile(paths.participants, subj, '06_roi', sprintf('%s_roi.mat', roi_name));

D = mardo(spm_file);
R = maroi(roi_file);
Y = get_marsy(R, D, 'mean');

E = estimate(D, Y);

[eSpecs, eNames] = event_specs(E);
nEvents = size(eSpecs, 2);
dur = 0;

for condition = 1:nEvents

    timeCourses(:, condition) = event_fitted(E, eSpecs(:, condition), dur);
end

figure;
plot(timeCourses);
legend(eNames);


