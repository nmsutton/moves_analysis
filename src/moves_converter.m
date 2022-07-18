% this software converts moves above a speed threshold
% into more moves that are below the threshold.

anim_angles = readmatrix('animal_angles.csv');
anim_speeds = readmatrix('animal_speeds.csv');
speed_limit = 5; % maximum speed allowed
speed_mult = 65; % multiplier of original speeds
write_output = 1; % write files or make matrices
anim_angles_limit = []; anim_speeds_limit = []; 
if write_output
	angles_file = fopen('anim_angles_limited.cpp','w');
	fprintf(angles_file,"vector<double> anim_angles = {");
end
if write_output
	speeds_file = fopen('anim_speeds_limited.cpp','w');
	fprintf(speeds_file,"vector<double> anim_speeds = {");
end
if speed_mult ~= 1
	anim_speeds = anim_speeds * speed_mult;
end

for i=1:length(anim_speeds)
	limit_detected = 0;
	if anim_speeds(i) > speed_limit
		limit_detected = 1;
		tg = ceil(anim_speeds(i)/speed_limit); % number of times greater than threshold
		for j=1:tg
			if j ~= tg
				new_speed = speed_limit;
			else
				new_speed = anim_speeds(i)-(speed_limit*(tg-1));
			end
			if write_output
				fprintf(angles_file,'%.6f',anim_angles(i));	
				fprintf(speeds_file,'%.6f',new_speed);	
			else
				anim_angles_limit = [anim_angles_limit; anim_angles(i)];
				anim_speeds_limit = [anim_speeds_limit; new_speed];
			end
			if i ~= length(anim_speeds) && write_output
				fprintf(angles_file,',',anim_angles(i));	
				fprintf(speeds_file,',',anim_speeds(i));
			end
		end
	else
		if write_output
			fprintf(angles_file,'%.6f',anim_angles(i));	
			fprintf(speeds_file,'%.6f',anim_speeds(i));
		else
			anim_angles_limit = [anim_angles_limit; anim_angles(i)];
			anim_speeds_limit = [anim_speeds_limit; anim_speeds(i)];
		end
	end
	if i ~= length(anim_speeds) && limit_detected ~= 1 && write_output
		fprintf(angles_file,',',anim_angles(i));	
		fprintf(speeds_file,',',anim_speeds(i));
	end
	if mod(i,5000)==0
		fprintf("%.1f%% completed\n",i/length(anim_speeds)*100);
	end
end

if write_output
	fprintf(angles_file,"};");
	fclose(angles_file);
	fprintf(speeds_file,"};");
	fclose(speeds_file);
end