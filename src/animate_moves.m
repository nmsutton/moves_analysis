% reference https://www.mathworks.com/help/matlab/ref/animatedline.html#:~:text=Create%20an%20animation%20by%20adding,loop%20using%20the%20addpoints%20function.&text=an%20%3D%20animatedline(%20x%20%2C%20y%20)%20creates%20an%20animated%20line,x%20%2C%20y%20%2C%20and%20z%20.

% run options
plot_animation = 0;
plot_last_time = 1;

time=100000;
timestep=20;
%moves=time/timestep;
moves=time;

if plot_animation
	h = animatedline();
	for i = 1:moves
    %for i = (375000/timestep):moves
		addpoints(h,Xs(i),Ys(i));
		drawnow
	end
end

if plot_last_time
	plot(Xs(1:moves),Ys(1:moves))
    %plot(Xs,Ys)
    %plot(Xs2,Ys2)
    %plot(Xs((374000/timestep):moves),Ys((374000/timestep):moves))
    %plot(Xs(371000:moves),Ys(371000:moves))
end

%{
% clear points
clearpoints(h)
drawnow
%}
