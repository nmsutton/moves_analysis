%%
%% Script to load trajectory of animal movement
%% c_ts: firing times, root.cel_x{1,1}: spike x coordinates,
%% root.cel_y{1,1}: spike y coordinates
%% reference: https://github.com/hasselmonians/CMBHOME/wiki/Tutorial-2:-Apply-an-epoch-and-get-theta-signal
%%

function pos=load_and_format_traj(file_to_reformat, cell_selection, y_offset, total_time, time_step)
    addpath /comp_neuro/Software/Github/CMBHOME_github/
    load(file_to_reformat);
    total_time=total_time/time_step; % convert to time steps used in recording
    root.cel = cell_selection; % select cell of interest
    CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
    pos = [root.x(1:total_time)'; root.y(1:total_time)'-y_offset; root.ts(1:total_time)'];
end