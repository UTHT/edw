function [integrand1, integrand2, integrand3] = EDW_calc_series(eta,mu_o,ro,ri,Br,mu_r,P,rspeed,vx,sigma,b,g,num_of_wheels,d,w_angle)
% this function returns the integrand to numerically compute the integral
% of thrust, lift and power respectively
% INPUTS: 
%   eta - fourier transform variable
%   mu_o - the permeability of free space [H/m]
%   ro - the outer radius of the rotor [m]
%   ri - the inner radius of the rotor [m]
%   Br - remanance of the permanent magnet in the rotor [T]
%   mu_r - relative magnetic permeability of the permanent magnet in the
%   rotor [-]
%   P  - pole pair in the Halbach array [-]
%   rspeed - mechanical rotational speed of the rotor [rad/s]
%   vx - translational speed of the rotor [m/s]
%   sigma - conductivity of the plate [S/m]
%   b - conductive plate thickness [m]
%   g - air gap between the rotor and conductive plate [m]

rspeede = P*rspeed; % electrical rotational speed (rad/s) or source frequency

%%------ magnetic field from the rotor via Hallbach rotor ------%%
% constant in the model
nominator = (1 + mu_r)*(ro^(2*P))*(ro^(P+1) - ri^(P+1)); % nominator of constant C
denom = ((1 - mu_r)^2)*(ri^(2*P)) - ((1 + mu_r)^2)*(ro^(2*P)); % denominator of constant C
C = -((2*Br*P)/(P+1))*(nominator/denom); % constant to calculate for B field

% fourier transformed B-field in the x and y-dir of rotor (source) field at y = b
if eta >= 0 % to take into account the heaviside function
    for k = 1:num_of_wheels
        CC = exp(sqrt(-1)*P.*(w_angle.*(k-1))); % constant to account for wheel offset angle      
        By_si(k) = (((-sqrt(-1)).^(P+1)).*2./(factorial(P))).*C.*CC.*pi.*(eta.^P).*exp(-eta.*(g + ro -(d + 2.*ro).*sqrt(-1).*(k -1) )); % B-field in the y-direction when eta > 0
    end
    By_s = sum(By_si); % sum of B-field in the y-direction for each wheel in series
else 
    Bx_s = 0;
    By_s = 0;
    Bxy_s = 0;
end


Bxy_s = 2.*sqrt(-1).*By_s; % source B-field Bx_s + j*By_s


% fourier transformed field on the conducting plate
gamma = sqrt((eta.^2) - sqrt(-1).*mu_o.*sigma.*(rspeede - vx.*eta)); % constant from fourier transform of B field on the conducting plate
denom2 = exp(gamma.*b).*((gamma + eta).^2) - exp(-gamma.*b).*((gamma - eta).^2); % denominator part of the fourier transform

% magnetic vector potential from the conducting plate Az at y = b (surface
% of plate)
T = ((gamma + eta).*exp(gamma.*b) + (gamma - eta).*exp(-gamma.*b))./(denom2); %"transmission function" of the source field
Az = T.*Bxy_s; % magnetic vector potential A in the conducting region

% finding Bx, By and their conjugates for the B field from the conducting
% plate
Bx = (gamma.*(gamma + eta).* exp(gamma.*b) - gamma.*(gamma - eta).*exp(-gamma.*b)).*Bxy_s./denom2; % B-field in the x-dir
By = -sqrt(-1).*eta.*T.*Bxy_s; % B-field on the conducting plate in the y-dir
Bx_conj = conj(Bx); % complex conjugate of Bx
By_conj = conj(By); % complex conjugate of By

% thrust force (Fx) integrand
integrand1 = real(Bx.*By_conj);

% Lift force (Fy) integrand
integrand2 = real(By.*By_conj - Bx.*Bx_conj);
 
% Power transferred integrand
integrand3 = real(sqrt(-1).*rspeede.*Az.*Bx_conj);
