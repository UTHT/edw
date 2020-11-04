% 2D analytical model based on Paudel & Bird 2012 "General 2D steady state force
% and power equations for a travelling time-varying magnetic source above a
% conductive plate"
clear
clc
close 
%% --------------- Wheel and Plate parameters ----------%%
mu_o = 4*pi*10^-7; % permeability of free space [H/m]
p = 7007;           % density of magnets [kg/m^3]
g = 9.81;

% Rotor/wheel specifications
ro = [0.10]; % outer radius of rotor [m]
ri = [0.075]; % inner radius of rotor [m]
w = 0.025; % magnet width [m]
Br = [1.42]; % magnet remanence [T]
mu_r = 1.08; % relative permeability

P = [3 4 5 6 7]; % pole pairs
slip = [-20:5:100]; % slip speed at top interface[m/s]
vx = [0 25 50 100 140]; % translational speed of the wheel [m/s]

num_of_wheels = [1]; % number of wheels in series
d = [0.1]; % separation distance between wheels [m]
w_angle = [4.0841]; % wheel offset angle between wheels [rad]
L = [0.8]; % track length [m]

% Conductive plate specifications
sigma1 = [0.5e7 1e7 1.5e7 2e7 3e7]; % conductivity of top aluminium track [S/m]
b1 = [1/1000:1/1000:5/1000]; % top track thickness [m]
g1 = [5/1000]; % air gap at top thrust interface [m]

sigma2 = [3.5e7]; % conductivity of bottom aluminium track [S/m]
b2 = [12.7/1000]; % bottom track thickness [m]
g2 = [10/1000];  % air gap at bottom levitation interface [m]

%% ------------ Thrust, lift, power total, power loss, thrust efficiency calculation ------------ %%
eta = linspace(-10000,10000, 100000); % Fourier transform variable -Inf to Inf

% Choose optimized values
i_ro = 1;
i_ri = 1;
i_Br = 1;
i_P = 3;
i_slip = 1;
i_vx = 3;
i_num_of_wheels = 1;
i_d = 1;
i_w_angle = 1;
i_L = 1;
i_sigma1 = 2;
i_sigma2 = 1;
i_b1 = 3;
i_b2 = 1;
i_g1 = 1;
i_g2 = 1;

colors = ["red", "cyan", "blue", "green", "magenta", "yellow"];

% loop through w_angle or vx and slip values to find thrust, lift, power total, and
% power loss

% To change which parameter to iterate over, change below
iter_name = 'vx';           % Change here
for ii = 1:length(vx)       % Here
    i_vx = ii;              % Here
    iter_value = vx(i_vx);   % And here
    
    mass(ii) = (pi*ro(i_ro)^2 - pi*ri(i_ri)^2) * w * p;  % Total mass in kg

    for i_slip = 1:length(slip)        
        % Top track
        rspeed1(i_slip) = (slip(i_slip) + vx(i_vx))/(ro(i_ro)); % rotor speed or angular speed [rad/s]
        for i = 1:length(eta)
            [Y1_1(i), Y2_1(i), Y3_1(i)] = EDW_calc_series_top_plate(eta(i),mu_o,ro(i_ro),ri(i_ri),Br(i_Br),mu_r,P(i_P),rspeed1(i_slip),vx(i_vx),sigma1(i_sigma1),b1(i_b1),g1(i_g1),num_of_wheels(i_num_of_wheels),d(i_d),w_angle(i_w_angle)); % calculating the integrand
        end   
        Ft_1(i_slip) = (1/(4*pi*mu_o))*real(trapz(eta,Y1_1)).*w; % numerical integration of thrust force [N]
        Fl_1(i_slip) = -(1/(8*pi*mu_o))*real(trapz(eta,Y2_1)).*w; % numerical integration of guidance force [N]
        Power_1(i_slip) = -(1/(4*pi*mu_o))*real(trapz(eta,Y3_1)).*w; % numerical integration of power transferred [W]
        Power_loss_1(i_slip) = (Power_1(i_slip) - Ft_1(i_slip).*vx(i_vx));  % power loss due to track [W]
        Thrust_eff_1(i_slip) = (Ft_1(i_slip).*vx(i_vx))/Power_1(i_slip); % efficiency due to forces created on the guideway
        LT_ratio_1(i_slip) = Fl_1(i_slip)./Ft_1(i_slip); %lift to thrust ratio
        
        % Bottom track
        rspeed2(i_slip) = (-slip(i_slip) - vx(i_vx))/(ro(i_ro)); % rotor speed or angular speed [rad/s]
        for i = 1:length(eta)
            [Y1_2(i), Y2_2(i), Y3_2(i)] = EDW_calc_series(eta(i),mu_o,ro(i_ro),ri(i_ri),Br(i_Br),mu_r,P(i_P),rspeed2(i_slip),vx(i_vx),sigma2(i_sigma2),b2(i_b2),g2(i_g2),num_of_wheels(i_num_of_wheels),d(i_d),w_angle(i_w_angle)); % calculating the integrand
        end
        Ft_2(i_slip) = (1/(4*pi*mu_o))*real(trapz(eta,Y1_2)).*w; % numerical integration of drag force [N]
        Fl_2(i_slip) = -(1/(8*pi*mu_o))*real(trapz(eta,Y2_2).*w); % numerical integration of lift force [N]
        Power_2(i_slip) = -(1/(4*pi*mu_o))*real(trapz(eta,Y3_2)).*w; % numerical integration of power transferred [W]
        Power_loss_2(i_slip) = (Power_2(i_slip) - Ft_2(i_slip).*vx(i_vx));  % power loss due to track[W]
        Thrust_eff_2(i_slip) = abs(Ft_2(i_slip).*vx(i_vx))/Power_2(i_slip); % efficiency due to forces created on the guideway
        LT_ratio_2(i_slip) = Fl_2(i_slip)./Ft_2(i_slip); %lift to thrust ratio
        
        Ft(i_slip) = Ft_1(i_slip) + Ft_2(i_slip);
        Power(i_slip) = Power_1(i_slip) + Power_2(i_slip);
        Power_loss(i_slip) = Power_loss_1(i_slip) + Power_2(i_slip);
        Thrust_eff(i_slip) = (Ft_1(i_slip).*vx(i_vx))/Power(i_slip);
        LT_ratio(i_slip) = abs(Fl_2(i_slip)./Ft_1(i_slip));
        LW_ratio(i_slip) = (Fl_2(i_slip)./g)./mass(ii);
    end
    
    %plots
    subplot(2,3,1)
    plot(slip,2*Ft/1000,'-.', 'LineWidth', 1.5, 'Color', colors(ii))
    hold all
    plot(slip,2*Ft_1/1000,':x', 'Color', colors(ii))
    plot(slip,2*Ft_2/1000,':+', 'Color', colors(ii))
    xlabel('Slip [m s^{-1}]')
    ylabel('Thrust Force [kN]')
    legend('Total','Thrust','Drag')
    grid on
    %set(gca,'FontSize',16)
    
    subplot(2,3,2)
    plot(slip,2*Fl_2/1000,'-.', 'LineWidth', 1.5, 'Color', colors(ii))
    hold all
    plot(slip,Fl_1/1000,':x', 'Color', colors(ii))
    xlabel('Slip [m s^{-1}]')
    ylabel('Lift Force [kN]')
    legend('Bottom Levition','Top Interface (not doubled)')
    grid on    
    if ii == 1
        title(['Mass = ', num2str(mass(ii)), ... 
            'kg, ro = ', num2str(ro(i_ro)), ...
            'm, ri = ', num2str(ri(i_ri)), ...
            'm, w = ', num2str(w), ...
            'm, P = ', num2str(P(i_P)), ...
            ', num wheels = ', num2str(num_of_wheels(i_num_of_wheels)), ...
            ', sigma1 = ', num2str(sigma1(i_sigma1)), ...
            'S/m, b1 = ' num2str(b1(i_b1)), ...
            'm, g1 = ' num2str(g1(i_g1)), ...
            'm, sigma2 = ', num2str(sigma2(i_sigma2)), ...
            'S/m, b2 = ', num2str(b2(i_b2)), ...
            'm, g2 = ', num2str(g2(i_g2)), 'm'])
    end
    %set(gca,'FontSize',16)

    
    subplot(2,3,3)
    plot(slip,2*Power/1000,'-.', 'LineWidth', 1.5, 'Color', colors(ii))
    hold all
    plot(slip,2*Power_1/1000,':x', 'Color', colors(ii))
    plot(slip,2*Power_2/1000,':+', 'Color', colors(ii))
    xlabel('Slip [m s^{-1}]')
    ylabel('Power [kW]')
    legend('Total', 'Top Interface', 'Bottom Interface')
    grid on
    %set(gca,'FontSize',16)
    
    subplot(2,3,4)
    plot(slip,2*Power_loss/1000,'-.', 'LineWidth', 1.5, 'Color', colors(ii))
    hold all
    plot(slip,2*Power_loss_1/1000,':x', 'Color', colors(ii))
    plot(slip,2*Power_2/1000,':+', 'Color', colors(ii))
    xlabel('Slip [m s^{-1}]')
    ylabel('Power loss [kW]')
    legend('Total', 'Top Interface', 'Bottom Interface')
    grid on
    %set(gca,'FontSize',16)
    
    subplot(2,3,5)
    plot(slip,Thrust_eff,'-.', 'LineWidth', 1.5, 'Color', colors(ii))
    hold all
    plot(slip,Thrust_eff_1,':x', 'Color', colors(ii))
    legend('Total', 'Top Interface')
    xlabel('Slip [m s^{-1}]')
    ylabel('\eta_{eff}')
    ylim([0, 1])
    grid on
    if ii == 1
    title("All values are for wheels on both sides of track (doubled) unless specified")
    end
    %set(gca,'FontSize',16)
    
    subplot(2,3,6)
    plot(slip,LT_ratio,'-.', 'LineWidth', 1.5, 'DisplayName',[iter_name, ' = ', num2str(iter_value)], 'Color', colors(ii))
    hold all
    ylabel('Lift-to-thrust ratio')
    ylim([0,10])
    xlabel('Slip [m s^{-1}]')
    legend show
    grid on
    %set(gca,'FontSize',16)

    mass
end
