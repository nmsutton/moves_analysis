%addpath /comp_neuro/Software/CMBHOME/CMBHOME/
addpath /comp_neuro/Software/Github/CMBHOME_github/
load('/media/nmsutton/StorageDrive7/comp_neuro/holger_data/180815_S1_S2_lightVSdarkness_merged.mat');
root.cel = [2,5];
c_ts = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
x = root.x; y= root.y; t = root.ts; %hd = CMBHOME.Utils.ContinuizeEpochs(root.headdir);
pos = [reshape(x-180,1,270000);reshape(y-840,1,270000);reshape(t,1,270000)];