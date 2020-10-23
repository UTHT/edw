% 2D analytical model based on Paudel & Bird 2012 "General 2D steady state force
% and power equations for a travelling time-varying magnetic source above a
% conductive plate"
clear
clc
close 
%% --------------- Wheel and Plate parameters ----------%%
mu_o = 4*pi*10^-7; % permeability of free space [H/m]

% Rotor/wheel specifications
ro = 0.07; % outer radius of rotor [m]
ri = 0.04788; % inner radius of rotor [m]
Br = 1.42; % magnet remanence [T]
mu_r = 1.08; % relative permeability

P = 4; % pole pairs
slip = [-30:5:30]; % slip speed [m/s]
vx = 30; % translational speed of the wheel [m/s]

num_of_wheels = 1; % number of wheels in series
d = 0.1; % separation distance between wheels [m]
w_angle = [4.0841 6.28]; % wheel offset angle between wheels [rad]
w = 0.2; % magnet width [m]

% Conductive plate specifications
sigma = 2.459e7; % conductiviety of aluminum plate [S/m]
b = 10/1000; % plate thickness [m]
g = 10/1000; % air gap between rotor and plate [m]
L = 0.8; % track length [m]


%% ------------ Thrust, lift, power total, power loss, thrust efficiency calculation ------------ %%
eta = linspace(-10000,10000, 100000); % Fourier transform variable -Inf to Inf

% loop through w_angle or vx and slip values to find thrust, lift, power total, and
% power loss
for ii = 1:length(w_angle)
    for jj = 1:length(slip)
        rspeed(jj) = (slip(jj) + vx)/(ro); % rotor speed or angular speed [rad/s]
        for i = 1:length(eta)
            [Y1(i), Y2(i), Y3(i)] = EDW_calc_series(eta(i),mu_o,ro,ri,Br,mu_r,P,rspeed(jj),vx,sigma,b,g,num_of_wheels,d,w_angle(ii)); % calculating the integrand
        end   
        Ft(jj) = (1/(4*pi*mu_o))*real(trapz(eta,Y1)); % numerical integration of thrust force per unit width of magnet [N/m]
        Fl(jj) = -(1/(8*pi*mu_o))*real(trapz(eta,Y2)); % numerical integration of lift force per unit width of magnet [N/m]
        Power(jj) = -(1/(4*pi*mu_o))*real(trapz(eta,Y3)); % numerical integration of power transferred / unit width of magnet [W/m]
        Power_loss(jj) = (Power(jj) - Ft(jj).*vx);  % power loss due to track/ unit width of magnet [W/m]
        Thrust_eff(jj) = (Ft(jj).*vx)/(Ft(jj).*vx + Power_loss(jj)); % efficiency due to forces created on the guideway
        LT_ratio(jj) = Fl(jj)./Ft(jj); %lift to thrust ratio
    end
    
    %plots
    subplot(2,3,1)
    plot(slip,Ft/1000,'o-')
    hold on
    xlabel('Slip [m s^{-1}]')
    ylabel('Thrust Force [kN m^{-1}]')
    grid on
    set(gca,'FontSize',16)
    
    subplot(2,3,2)
    plot(slip,Fl/1000,'o-')
    hold all
    xlabel('Slip [m s^{-1}]')
    ylabel('Lift Force [kN m^{-1}]')
    grid on
    set(gca,'FontSize',16)
    
    subplot(2,3,3)
    plot(slip,Power/1000,'o-')
    hold all
    xlabel('Slip [m s^{-1}]')
    ylabel('Power [kW m^{-1}]')
    grid on
    set(gca,'FontSize',16)
    
    subplot(2,3,4)
    plot(slip,Power_loss/1000,'o-')
    hold all
    xlabel('Slip [m s^{-1}]')
    ylabel('Power loss [kW m^{-1}]')
    grid on
    set(gca,'FontSize',16)
    
    subplot(2,3,5)
    plot(slip,Thrust_eff,'o-')
    hold all
    xlabel('Slip [m s^{-1}]')
    ylabel('\eta_{eff}')
    grid on
    set(gca,'FontSize',16)
    
    subplot(2,3,6)
    plot(slip,LT_ratio,'o-','DisplayName',['\theta = ', num2str(w_angle(ii))])
    hold all
    xlabel('Slip [m s^{-1}]')
    ylabel('Lift-to-thrust ratio')
    legend show
    grid on
    set(gca,'FontSize',16)
    
  
end

