% Look at effects of stimulus timing on HRF model

% Overview of design power/efficiency
%    https://imaging.mrc-cbu.cam.ac.uk/imaging/DesignEfficiency

% Metric for efficiency for a specific design matrix X and contrast C
%   e(C,X) = trace( C'*inv(X'X)*C )^-1


%% Template design info
% Set up a template structure in SPM batch format with basic info. 60 scans
% at 2 sec TR = 2 minute experiment. TR, experiment duration, etc probably
% need to be the same to compare efficiency values between designs
clear template
template{1}.spm.stats.fmri_design.timing.units = 'secs';
template{1}.spm.stats.fmri_design.timing.RT = 2;
template{1}.spm.stats.fmri_design.sess.nscan = 60;
template{1}.spm.stats.fmri_design.timing.fmri_t = 16;
template{1}.spm.stats.fmri_design.timing.fmri_t0 = 8;
template{1}.spm.stats.fmri_design.sess.cond.tmod = 0;
template{1}.spm.stats.fmri_design.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
template{1}.spm.stats.fmri_design.sess.cond.orth = 1;
template{1}.spm.stats.fmri_design.sess.multi = {''};
template{1}.spm.stats.fmri_design.sess.regress = struct('name', {}, 'val', {});
template{1}.spm.stats.fmri_design.sess.multi_reg = {''};
template{1}.spm.stats.fmri_design.sess.hpf = 300;
template{1}.spm.stats.fmri_design.fact = struct('name', {}, 'levels', {});
template{1}.spm.stats.fmri_design.bases.hrf.derivs = [0 0];
template{1}.spm.stats.fmri_design.volt = 1;
template{1}.spm.stats.fmri_design.global = 'None';
template{1}.spm.stats.fmri_design.mthresh = 0.8;
template{1}.spm.stats.fmri_design.cvi = 'AR(1)';


%% Extreme case 1
% Continuous events for 120 sec, no ISI. Onsets/durations are specified in
% seconds.
tag = 1;
onsets = 0:3:120;
durations = repmat(3,size(onsets));

% Use SPM batch code to configure design
matlabbatch = template;
matlabbatch{1}.spm.stats.fmri_design.dir = {['spmdir' num2str(tag)]};
matlabbatch{1}.spm.stats.fmri_design.sess.cond.name = 'Task';
matlabbatch{1}.spm.stats.fmri_design.sess.cond.onset = onsets;
matlabbatch{1}.spm.stats.fmri_design.sess.cond.duration = durations;

% Run the design setup and load result
spm_jobman('run',matlabbatch);
load(fullfile(matlabbatch{1}.spm.stats.fmri_design.dir{1},'SPM.mat'));

% Compute efficiency for the first regressor, contrast = [1 0]'
C = [1 0]';
eff = trace( C'*inv(SPM.xX.X'*SPM.xX.X)*C )^-1;

% View the HRF
figure(tag); clf
plot(SPM.xX.X(:,1))
title(sprintf('Efficiency = %0.2f',eff))


%% Extreme case 2
% Block design, 30 sec on / 30 sec off
tag = 2;
onsets = [0:3:27 60:3:87];
durations = repmat(3,size(onsets));

% Same code as above for the rest
matlabbatch = template;
matlabbatch{1}.spm.stats.fmri_design.dir = {['spmdir' num2str(tag)]};
matlabbatch{1}.spm.stats.fmri_design.sess.cond.name = 'Task';
matlabbatch{1}.spm.stats.fmri_design.sess.cond.onset = onsets;
matlabbatch{1}.spm.stats.fmri_design.sess.cond.duration = durations;
spm_jobman('run',matlabbatch);
load(fullfile(matlabbatch{1}.spm.stats.fmri_design.dir{1},'SPM.mat'));
C = [1 0]';
eff = trace( C'*inv(SPM.xX.X'*SPM.xX.X)*C )^-1;
figure(tag); clf
plot(SPM.xX.X(:,1))
title(sprintf('Efficiency = %0.2f',eff))


%% Case 3, random-ish ISI
tag = 3;
onsets = [0 3 10 15 18 25 41 45 52 55 78 100 103 106];
durations = repmat(3,size(onsets));

% Same code as above for the rest
matlabbatch = template;
matlabbatch{1}.spm.stats.fmri_design.dir = {['spmdir' num2str(tag)]};
matlabbatch{1}.spm.stats.fmri_design.sess.cond.name = 'Task';
matlabbatch{1}.spm.stats.fmri_design.sess.cond.onset = onsets;
matlabbatch{1}.spm.stats.fmri_design.sess.cond.duration = durations;
spm_jobman('run',matlabbatch);
load(fullfile(matlabbatch{1}.spm.stats.fmri_design.dir{1},'SPM.mat'));
C = [1 0]';
eff = trace( C'*inv(SPM.xX.X'*SPM.xX.X)*C )^-1;
figure(tag); clf
plot(SPM.xX.X(:,1))
title(sprintf('Efficiency = %0.2f',eff))

