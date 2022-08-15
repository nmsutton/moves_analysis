X_vals = [99.4807024100555];
Y_vals = [261.594645968746];

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

fprintf("x:%f y:%f\n",X_vals,Y_vals);