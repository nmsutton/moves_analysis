%%
%% Script to load spike firing times for a cell
%% c_ts: firing times, root.cel_x{1,1}: spike x coordinates,
%% root.cel_y{1,1}: spike y coordinates
%% reference: https://github.com/hasselmonians/CMBHOME/wiki/Tutorial-2:-Apply-an-epoch-and-get-theta-signal
%%
    
function pos=load_and_format_spikes(file_to_reformat, cell_selection, y_offset)
    addpath /comp_neuro/Software/Github/CMBHOME_github/
    load(file_to_reformat);
    root.cel = cell_selection; % select cell of interest
    c_ts = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
    pos = [root.cel_x{1,1}'; root.cel_y{1,1}'-y_offset; root.cel_ts{1,1}'];
end