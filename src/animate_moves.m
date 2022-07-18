% reference https://www.mathworks.com/help/matlab/ref/animatedline.html#:~:text=Create%20an%20animation%20by%20adding,loop%20using%20the%20addpoints%20function.&text=an%20%3D%20animatedline(%20x%20%2C%20y%20)%20creates%20an%20animated%20line,x%20%2C%20y%20%2C%20and%20z%20.

% run options
plot_animation = 0;
plot_last_time = 1;

time=30000;
timestep=20;
moves=time/timestep;

if plot_animation
	h = animatedline();
	for i = 1:moves
		addpoints(h,Xs(i),Ys(i));
		drawnow
	end
end

if plot_last_time
	plot(Xs(1:moves),Ys(1:moves))
end

%{
% clear points
clearpoints(h)
drawnow
%}
