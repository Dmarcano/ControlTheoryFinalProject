syms kp ki kd s t

Gplant = (10)/(s*(s^2 + 10*s + 10));

P_plant_step = kp*10/((s^3 + 10*s^2+10*s +10*kp));

FT_time_domain = ilaplace(P_plant_step);                       % Inverse Laplace Transform
FT_time_domain = simplify(FT_time_domain, 'Steps',2000);       % Simplify To Get Nice Result
FT_time_domain = collect(FT_time_domain, exp(-t));   

s = tf('s');
sys = (10)/((s^2 + 10*s + 10));
sys_step = sys/s; 

closed_loop = feedback(6*sys_step, 1);

% Extract the numerator/denominator
[num,den] = tfdata(closed_loop);

y = step(sys);

% tf(pid(1, 1, 1))