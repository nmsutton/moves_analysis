% test converting points to velocity then back to points

x = [195.096333105737,194.955405196334,194.663678022051,194.215017373334,193.670286789166,193.133919589554,192.693213797366,192.357493645630,192.040205689616,191.599972385252];
y = [268.171978535190,267.272809375070,266.584601060447,266.071771201756,265.841920128797,265.793701135508,265.665319706131,265.659553511222,265.574585181822,265.585669865744];
angles=[]; speeds=[]; Xs = []; Ys = [];

x1 = x(1);
y1 = y(1);
for i=1:length(x)
	x2 = x(i);
	y2 = y(i);
	angle = find_angle(x1, y1, x2, y2);
	speed = find_speed(x1, y1, x2, y2);
	y1 = y2;
	x1 = x2;
	angles=[angles;angle];
	speeds=[speeds;speed];
end

x1 = x(1);
y1 = y(1);
for i=1:length(x)
	a=angles(i);
	s=speeds(i);
	a=a/360 * pi*2;
    x1=cos(a)*s+x1;
	y1=sin(a)*s+y1;
	Xs=[Xs;x1];
	Ys=[Ys;y1];
end

% compare results
fprintf("original point|translated point\n");
for i=1:length(x)
	fprintf("%f,%f|%f,%f\n",x(i),y(i),Xs(i),Ys(i));
end

function angle = find_angle(x1, y1, x2, y2)
	deltaX = x2 - x1; 
	deltaY = y2 - y1; 
	angle = atan2d(deltaY,deltaX);
end

function speed = find_speed(x1, y1, x2, y2)
	% speed based on distance moved by euclidan distance
	speed = sqrt((x2-x1)^2+(y2-y1)^2);
end