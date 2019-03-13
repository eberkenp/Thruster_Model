function [n, T, Q] = Thruster_Throttle_Model(n0,Throttle, rho, Thruster_Config, dt)
%THRUSTER_MODEL time varying dynamic model of ROV thruster
%function [n, T, Q] = Thruster_Model(Va, n0, Throttle , rho, Thruster_Params, dt)
% T(t)=Ta+(To-Ta)*exp(-kt) 
%
%inputs:
%   n0 = [rps] current revolutions per second
%   Throttle = current throttle (-5 to 5)
%   rho = density of seawater
%   Thruster_Params = parameters of the thruster model
%   dt = simulation time step
%
%outputs:
%   n = [rps] thruster rate
%   T = [N] Output Thrust
%   Q = [Nm] Reaction Torque
%
%function to approximate T(t)=Ta+(To-Ta)*exp^{-kt}  
%
%dT/dt=-k(T-Ta). 
%T(0)=To  
%
%http://www.ugrad.math.ubc.ca/coursedoc/math100/notes/diffeqs/cool.html

Table_Throttles = Thruster_Config.Table_Throttles;
Table_n = Thruster_Config.Table_n;

n_command = throttle_to_n(Throttle,Table_Throttles, Table_n);
keyboard;
%Populate thruster params
D = Thruster_Config.D; %[m] propellor diameter
kv = Thruster_Config.kv; %[rate parameter]
cT1 = Thruster_Config.cT1;
cT2 = Thruster_Config.cT2;
dT1 = Thruster_Config.dT1;
dT2 = Thruster_Config.dT2;
cQ1 = Thruster_Config.cQ1;
cQ2 = Thruster_Config.cQ2;
dQ1 = Thruster_Config.dQ1;
dQ2 = Thruster_Config.dQ2;

%Va = 1E-1000;

%Update thruster rate
% n_command = g*Throttle;
% d_n = -k*(n0-n_command);
if Thruster_Config.RH_prop
    d_n = kv*(n_command-n0); % RH prop
else
    d_n = kv*(n_command-n0); % LH prop
end

n = n0+d_n*dt;

%Calculate Advance Coefficient
if (n==0) 
   n = 1E-100;
end
if isinf(n)
    n=1E100*sign(n);
end

% Calculate deadband piecewise quadratic coefficients:
if n*abs(n)<=dT1
    alpha1 = cT1*((n*abs(n))-dT1);
elseif n*abs(n)>=dT2
    alpha1 = cT2*((n*abs(n))-dT2);
else
    alpha1 = 0;
end
if n*abs(n)<=dQ1
    beta1 = cQ1*((n*abs(n))-dQ1);
elseif n*abs(n)>=dQ2
    beta1 = cQ2*((n*abs(n))-dQ2);
else
    beta1 = 0;
end

%Calculate Thrust
T = rho*D^4*alpha1; %[N] thrust

%Calculate Torque
if Thruster_Config.RH_prop
    Q = rho*D^5*beta1; %[Nm] torque
else
    Q = -rho*D^5*beta1; %[Nm] torque
end
if (isnan(T))
    keyboard;
end
