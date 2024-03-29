% unwrap animal positions that wrapped around a taurus in the simulation
% for the purposes of plotting animal movements

use_hopper = 0;
hopper_run = 5;
use_laptop = 0;

%Xs = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_cs4/scripts/high_res_traj/anim_trajx.csv');
%Ys = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_cs4/scripts/high_res_traj/anim_trajy.csv');
if use_hopper == 1
    hopper_path=(['/mnt/hopper_scratch/gc_sim/',int2str(hopper_run),'/spikes/highres_pos_x.csv']);
    Xs = readmatrix(hopper_path);
    hopper_path=(['/mnt/hopper_scratch/gc_sim/',int2str(hopper_run),'/spikes/highres_pos_y.csv']);
    Ys = readmatrix(hopper_path);
else
    if use_laptop == 0
        Xs = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_cs4/output/spikes/highres_pos_x.csv');
        Ys = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_cs4/output/spikes/highres_pos_y.csv');
    else
        Xs = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_ltop/output/spikes/highres_pos_x.csv');
        Ys = readmatrix('/home/nmsutton/Dropbox/CompNeuro/gmu/research/sim_project/code/gc_can_ltop/output/spikes/highres_pos_y.csv');
    end
end

write_csv_files=1;
Xs2 = Xs; Ys2 = Ys;
wrap_right = 0; % wrapping detection variable
wrap_left = 0;
wrap_top = 0;
wrap_bottom = 0;
thresh = 15; % threshold of movement to detect start of wrapping
thresh_end = 15; % threshold of movement to detect end of wrapping
max_x = 30;
max_y = 30;

if write_csv_files
	Xs_output_file = fopen('output/Xs_unwrapped.csv','w');
	Ys_output_file = fopen('output/Ys_unwrapped.csv','w');
end

for i=1:length(Xs)
	if i==1
		x1 = Xs(1); y1 = Ys(1); 
	else
		x1 = Xs(i-1); y1 = Ys(i-1);
	end
	x2 = Xs(i);
	y2 = Ys(i);
	% detect wrap start
	if x2 - x1 < -thresh && wrap_left == 0
		wrap_right=1;
		%fprintf("wrap right start: %d %f %f\n",i,x2,x1);
	end
	if x2 - x1 > thresh && wrap_right == 0
		wrap_left=1;
		%fprintf("wrap left start: %d %f %f\n",i,x2,x1);
	end
	if y2 - y1 < -thresh && wrap_bottom == 0
		wrap_top=1;
		%fprintf("wrap top start: %d %f %f %f %f\n",i,y2,y1,(y2-y1),-thresh);
	end
	if y2 - y1 > thresh && wrap_top == 0
		wrap_bottom=1;
		%fprintf("wrap bottom start: %d %f %f %f %f\n",i,y2,y1,(y2-y1),thresh);
	end
	% detect wrap end
	if x2 > max_x-thresh_end && wrap_right
		wrap_right=0;
		%fprintf("wrap right end: %d %f %f\n",i,x2,x1);
	end
	if x2 < thresh_end && wrap_left
		wrap_left=0;
		%fprintf("wrap left end: %d %f %f\n",i,x2,x1);
	end
	if y2 > max_y-thresh_end && wrap_top
		wrap_top=0;
		%fprintf("wrap top end: %d %f %f\n",i,y2,y1);
	end
	if y2 < thresh_end && wrap_bottom
		wrap_bottom=0;
		%fprintf("wrap bottom end: %d %f %f\n",i,y2,y1);
	end

	if wrap_right
		Xs2(i)=Xs2(i)+max_x;
	end
	if wrap_left
		Xs2(i)=Xs2(i)-max_x;
	end
	if wrap_top
		Ys2(i)=Ys2(i)+max_x;
	end
	if wrap_bottom
		Ys2(i)=Ys2(i)-max_x;
	end
	if write_csv_files
		fprintf(Xs_output_file,'%.6f\n',Xs2(i));	
		fprintf(Ys_output_file,'%.6f\n',Ys2(i));
	end
	if mod(i,(length(Xs)/10))==0
		fprintf("%.1f%% completed\n",i/length(Xs)*100);
	end	
end

if write_csv_files
	fclose(Xs_output_file);
	fclose(Ys_output_file);
end