%Approximate (simulate) an exponential function by integrating the derivative
%
%function to approximate y(t) = C*Vb*(1-exp(-t/(R*C)))

%Simulation
dt = 0.01;
t_n = [0:dt:5];
R = 1;
C = 1;
Vb = 1;
y0 = C*Vb*(1-exp(-0/(R*C)));
index = 1;
y_n = y0;
while(t_n(index)<max(t_n));
    dy(index) = (Vb*exp(-t_n(index)/(R*C))/R)*dt;
    y_n(index+1) = y_n(index)+dy(index);
    index = index + 1;
end

%Calculate true Exponential
t = linspace(0,5,1000);
y = C*Vb*(1-exp(-t/(R*C)));

%Plot results
plot(t, y, t_n, y_n, '.k');