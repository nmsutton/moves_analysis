%%
%% Script to load trajectory of animal movement
%% c_ts: firing times, root.cel_x{1,1}: spike x coordinates,
%% root.cel_y{1,1}: spike y coordinates
%% references: https://github.com/hasselmonians/CMBHOME/wiki/Tutorial-2:-Apply-an-epoch-and-get-theta-signal
%% https://www.mathworks.com/matlabcentral/answers/432322-rotate-a-2d-plot-around-a-specific-point-on-the-plot
%%

function pos=load_and_format_traj(file_to_reformat, cell_selection, y_offset, total_time, time_step, trans_correct)
    addpath /comp_neuro/Software/Github/CMBHOME_github/
    load(file_to_reformat);
    total_time=total_time/time_step; % convert to time steps used in recording
    root.cel = cell_selection; % select cell of interest
    CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
    X_vals = root.x(1:total_time)';
    Y_vals = root.y(1:total_time)'-y_offset;
    if trans_correct
        Xc = 180; % center of x vals
        Yc = 180; % center of y vals        
        % rotate 90 degrees clockwise
        Xs = X_vals - Xc; % shift data
        Ys = Y_vals - Yc;
        Xsr = Ys; % rotate data 90 degrees clockwise
        Ysr = -Xs;
        Xr = Xsr + Xc; % unshift rotated data
        Yr = Ysr + Yc;
        % flip horizonally
        Xcd = Xc - Xr; % distance of x values to center
        Xr2 = Xr + (Xcd*2); % add twice distance from center to bring around other side
        Yr2=Yr;
        X_vals = Xr2;
        Y_vals = Yr2;
    end
    pos = [X_vals; Y_vals; root.ts(1:total_time)'];
end