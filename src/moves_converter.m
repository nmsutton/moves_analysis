% This software converts moves into cpp and csv files.
% There are speed_limit and speed_mult options.

anim_angles = readmatrix('output/animal_angles.csv');
anim_speeds = readmatrix('output/animal_speeds.csv');
use_speed_limit = 0; % turn speed limit on or off
speed_limit = 25; % maximum speed allowed
speed_mult = 54;%60;%60; % multiplier of original speeds
timestep = 20;
max_time = length(anim_speeds)*timestep;%2400000; % max time of moves to save to files
max_moves = max_time/timestep;
mi = 0; % move index
write_cpp_output = 1; % write files
write_csv_output = 1; % for hopper runs that import data with csv not cpp
output_matrices = 0;
anim_angles_limit = []; anim_speeds_limit = []; 
if write_cpp_output
	angles_cpp_file = fopen('output/anim_angles.cpp','w');
	fprintf(angles_cpp_file,"vector<double> anim_angles = {");
	speeds_cpp_file = fopen('output/anim_speeds.cpp','w');
	fprintf(speeds_cpp_file,"vector<double> anim_speeds = {");
end
if write_csv_output
	angles_csv_file = fopen('output/anim_angles.csv','w');
	speeds_csv_file = fopen('output/anim_speeds.csv','w');
end
if speed_mult ~= 1
	anim_speeds = anim_speeds * speed_mult;
end

for i=1:max_moves
	limit_detected = 0;
	if use_speed_limit && anim_speeds(i) > speed_limit
		limit_detected = 1;
		tg = ceil(anim_speeds(i)/speed_limit); % number of times greater than threshold
		for j=1:tg
			if j ~= tg
				new_speed = speed_limit;
			else
				new_speed = anim_speeds(i)-(speed_limit*(tg-1));
			end
			if write_cpp_output
				fprintf(angles_cpp_file,'%.6f',anim_angles(i));	
				fprintf(speeds_cpp_file,'%.6f',new_speed);	
			end
			if output_matrices
				anim_angles_limit = [anim_angles_limit; anim_angles(i)];
				anim_speeds_limit = [anim_speeds_limit; new_speed];
			end
			if write_csv_output
				fprintf(angles_csv_file,'%.6f\n',anim_angles(i));	
				fprintf(speeds_csv_file,'%.6f\n',new_speed);
			end
			if write_cpp_output && i ~= max_moves
				fprintf(angles_cpp_file,',',anim_angles(i));	
				fprintf(speeds_cpp_file,',',anim_speeds(i));
			end
		end
	else
		if write_cpp_output
			fprintf(angles_cpp_file,'%.6f',anim_angles(i));	
			fprintf(speeds_cpp_file,'%.6f',anim_speeds(i));
		end
		if output_matrices
			anim_angles_limit = [anim_angles_limit; anim_angles(i)];
			anim_speeds_limit = [anim_speeds_limit; anim_speeds(i)];
		end
		if write_csv_output
			fprintf(angles_csv_file,'%.6f\n',anim_angles(i));	
			fprintf(speeds_csv_file,'%.6f\n',anim_speeds(i));
		end
	end
	if write_cpp_output && i ~= max_moves && limit_detected ~= 1
		fprintf(angles_cpp_file,',',anim_angles(i));	
		fprintf(speeds_cpp_file,',',anim_speeds(i));
	end
	if mod(i,floor(max_moves/10))==0
		fprintf("%.1f%% completed\n",i/max_moves*100);
	end
end

if write_cpp_output
	fprintf(angles_cpp_file,"};");
	fclose(angles_cpp_file);
	fprintf(speeds_cpp_file,"};");
	fclose(speeds_cpp_file);
end

if write_csv_output
	fclose(angles_csv_file);
	fclose(speeds_csv_file);
end