% This software can reformat animal recordings for use in simulations.
% Also statistics can be generated about the animal movements in the data.
% 
% reference: https://www.mathworks.com/matlabcentral/answers/510528-transform-x-y-coordinate-to-angle

% run options
reformat_spike_data = 1; % choose to reformat data or load previously formatted data
% reformat file
file_to_reformat = '/media/nmsutton/StorageDrive7/comp_neuro/holger_data/merged_sessions_ArchTChAT#22_cell1';
cell_selection = [2,1]; % select cell of interest; [tetrode_number, cell_number]
y_offset = 660;
% load prior reformated file
prior_reformatted_file = '../data/191108_S1_lightVSdarkness_cells11and12_t1_c9_40min.mat';
if reformat_spike_data
    pos=load_and_format_spikes(file_to_reformat, cell_selection, y_offset)
else
	load(prior_reformatted_file);
end
% other run options
write_txt_file = 0; % option to write velocity data to txt file
write_csv_file = 1; % write seperate angle and speed csv files
find_fastest_rot = 0; % report fastest rotations
report_speed_bins = 0;

if write_txt_file
	moves_txt_file = fopen('reformatted_moves.txt','w');
end
if write_csv_file
	angles_csv_file = fopen('animal_angles.csv','w');
end
if write_csv_file
	speeds_csv_file = fopen('animal_speeds.csv','w');
end
ts = 0.02; % timestep
runtime = size(pos,2);%29416; % run time is number of timesteps in source file.
x0 = pos(1,1);
y0 = pos(2,1);
x1 = x0;
y1 = y0;
old_angle = 180;
angle_ranges = [[316,45];[46,135];[136,225];[226,315]];
bin_1s = 1/ts; % number of ts in 1 sec
bin_200ms = 0.2/ts; % number of ts in 200 ms
rotations_1s_bin = zeros(1,1+floor(runtime/bin_1s));
rotations_200ms_bin = zeros(1,1+floor(runtime/bin_200ms));
speeds_1s_bin = zeros(bin_1s,floor(runtime/bin_1s));
speeds_200ms_bin = zeros(bin_200ms,floor(runtime/bin_200ms));
all_speeds = zeros(1,runtime); % full set of speeds
all_rotations = zeros(1,runtime); % full set of speeds
all_angles = zeros(1,runtime); % full set of angles
maxes_1s_wdw = [];
means_1s_wdw = [];
maxes_200ms_wdw = []; % maxes in rolling window
means_200ms_wdw = []; % means in rolling window
sumrot_1s_wdw = [];
sumrot_200ms_wdw = [];
speed_bins = zeros(1,200); % set of speed value bins

for t=1:runtime
	if isnan(pos(1,t)) ~= 1 && isnan(pos(2,t)) ~= 1 % avoid NaN entries that cause later processing issues
		x2 = pos(1,t);
		y2 = pos(2,t);
	end
	i_1sec = 1 + floor(t/bin_1s); % 1 sec bin index
    i_col_1s = 1 + mod(t,bin_1s);
	i_200ms = 1 + floor(t/bin_200ms);
	i_col_200ms = 1 + mod(t,bin_200ms);

	% find binned rotations
	%angle = find_angle(x0, y0, x2, y2) + 180;
	angle = find_angle(x1, y1, x2, y2) + 180; % +180 is added to make range [0-360]
	all_angles(t) = angle;
	rotation = detect_angle_change(old_angle, angle, angle_ranges, t);
	if rotation == 1
		rotations_1s_bin(i_1sec) = rotations_1s_bin(i_1sec) + 1;
		rotations_200ms_bin(i_200ms) = rotations_200ms_bin(i_200ms) + 1;
	end

	% find binned speeds
	speed = find_speed(x1, y1, x2, y2);
	speeds_1s_bin(i_col_1s,i_1sec) = speed;
	speeds_200ms_bin(i_col_200ms,i_200ms) = speed;
    if report_speed_bins
	    sbi = 1+floor(speed*10); % speed bin index
	    speed_bins(sbi) = speed_bins(sbi) + 1;
    end

	% find rolling window rotations
	all_rotations(t) = rotation;
	if t > 1000
		wsum = find_rotations_rolling(t,1000/bin_1s,all_rotations);
		sumrot_1s_wdw = [sumrot_1s_wdw, wsum];
	end
	if t > 200
		wsum = find_rotations_rolling(t,200/bin_1s,all_rotations);
		sumrot_200ms_wdw = [sumrot_200ms_wdw, wsum];
	end

	% find rolling window speeds
	all_speeds(t) = speed;
	if t > 1000
		[wmax wmean] = find_speeds_rolling(t,1000/bin_1s,all_speeds);
		maxes_1s_wdw = [maxes_1s_wdw, wmax]; 
		means_1s_wdw = [means_1s_wdw, wmean]; 
	end	
	if t > 200
		[wmax wmean] = find_speeds_rolling(t,200/bin_200ms,all_speeds);
		maxes_200ms_wdw = [maxes_200ms_wdw, wmax]; 
		means_200ms_wdw = [means_200ms_wdw, wmean]; 
	end

	% store prior variables
	old_angle = angle;
	y1 = y2;
	x1 = x2;

	if write_txt_file
		fprintf(moves_txt_file,'%d,%f,%f\n',t*(ts*1000),angle,speed);		
	end
	if write_csv_file
		if t ~= runtime
			fprintf(angles_csv_file,'%f,',angle);		
			fprintf(speeds_csv_file,'%f,',speed);	
		else
			fprintf(angles_csv_file,'%f',angle);		
			fprintf(speeds_csv_file,'%f',speed);
		end
	end

	if mod(t,10000)==0
		fprintf("t:%d\n",t);
	end
end

if find_fastest_rot
	fastest_rot = 100000;
	for i=2:runtime
		angle = all_angles(i);		
		for j=2:i
			old_angle = all_angles(j);
			rot_speed = 100000;
			if abs(angle - old_angle) > 90
				rot_speed = i-j;
			end
			if rot_speed < fastest_rot
				fastest_rot = rot_speed;
				rot_start = angle;
				rot_end = old_angle;
				rot_start_t = j*20;
				rot_end_t = i*20;
			end
		end
	end
	fprintf("fastest_90deg+_rotation: %.3gms start_angle:%.4g end_angle:%.4g start_t:%.7gms end_t:%.7gms\n",fastest_rot*20,rot_start,rot_end,rot_start_t,rot_end_t);
end

% report statistics
disp("binned statistics:")
disp("rotations:")
fprintf("most rotations per second: %.3g\n",max(rotations_1s_bin));
fprintf("most rotations per 200ms: %d\n",max(rotations_200ms_bin));
fprintf("average rotations per second: %.4g\n",mean(rotations_1s_bin));
fprintf("average rotations per 200ms: %.4g\n",mean(rotations_200ms_bin));
disp("speeds:")
speeds_1s_max = max(speeds_1s_bin); speeds_200ms_max = max(speeds_200ms_bin);
speeds_1s_mean = mean(speeds_1s_bin); speeds_200ms_mean = mean(speeds_200ms_bin);
fprintf("highest speed per second: %.4g\n",max(speeds_1s_max));
fprintf("highest speed per 200ms: %.4g\n",max(speeds_200ms_max));
fprintf("average speed per second: %.4g\n",mean(speeds_1s_mean));
fprintf("average speed per 200ms: %.4g\n",mean(speeds_200ms_mean));
disp("rolling window statistics:")
disp("rotations:")
fprintf("most rotations per second: %.4g\n",max(sumrot_1s_wdw));
fprintf("most rotations per 200ms: %.4g\n",max(sumrot_200ms_wdw));
fprintf("average rotations per second: %.4g\n",mean(sumrot_1s_wdw));
fprintf("average rotations per 200ms: %.4g\n",mean(sumrot_200ms_wdw));
disp("speeds:")
fprintf("highest speed per second: %.4g\n",max(maxes_1s_wdw));
fprintf("highest speed per 200ms: %.4g\n",max(maxes_200ms_wdw));
fprintf("average speed per second: %.4g\n",mean(means_1s_wdw));
fprintf("average speed per 200ms: %.4g\n",mean(means_200ms_wdw));
%{
disp("binned speeds:")
for i = 1:length(speed_bins)
	fprintf("%f,%d\n",i*0.1,speed_bins(i));
end
%}

if write_txt_file
	fclose(moves_txt_file);
	fclose(angles_csv_file);
	fclose(speeds_csv_file);
end

function angle = find_angle(x1, y1, x2, y2)
	deltaX = x2 - x1; 
	deltaY = y2 - y1; 
	angle = atan2d(deltaY,deltaX);
end

function speed = find_speed(x1, y1, x2, y2)
	% speed based on distance moved by euclidan distance
	speed = sqrt((x2-x1)^2+(y2-y1)^2);
	f1 = 30/360; % 360x360 x,y to 30x30 x,y
	f2 = 1000/20; % distance per 20ms converted to distance per 1sec
	speed = speed*f1; 
end

function rotation = detect_angle_change(old_angle, new_angle, angle_ranges, t)
	rotation = 0; % report angle group change
	old_angle_group = 0;
	new_angle_group = 0;
	for i=1:length(angle_ranges(:,1))
		if i == 1
			if (old_angle) >= angle_ranges(i,1) || (old_angle) <= angle_ranges(i,2)
				old_angle_group = i;
			end
			if (new_angle) >= angle_ranges(i,1) || (new_angle) <= angle_ranges(i,2)
				new_angle_group = i;
			end
		else 
			if (old_angle) >= angle_ranges(i,1) && (old_angle) <= angle_ranges(i,2)
				old_angle_group = i;
			end
			if (new_angle) >= angle_ranges(i,1) && (new_angle) <= angle_ranges(i,2)
				new_angle_group = i;
			end
		end
	end
	if new_angle_group ~= old_angle_group
		rotation = 1;
		%fprintf("angle change at %d; old_angle: %d; new_angle: %d\n",t,old_angle,new_angle);
	end
end

function [wmax wmean] = find_speeds_rolling(t,window,all_speeds)
	window_speeds = [];
	for i=1:window
		window_speeds = [window_speeds, all_speeds(t-i)];
	end
	wmax = max(window_speeds);
	wmean = mean(window_speeds);
end

function wsum = find_rotations_rolling(t,window,all_rotations)
	window_rot = [];
	for i=1:window
		window_rot = [window_rot, all_rotations(t-i)];
	end
	wsum = sum(window_rot);
end