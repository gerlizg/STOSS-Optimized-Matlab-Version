addpath('C:\Users\Principal\Desktop\STOSS-MATLAB\STOSS-MATLAB');
clear 
clc

%###############################
%   Timer:
%###############################
tic

filename = 'user_configurations.xlsx';
data_vector = readtable(filename);
data = table2array (data_vector(:,2));
data = data(~isnan(data));

%###############################################
% GENERAL CONFIGURATIONS:
%###############################################
N_ex = data(1);                                            % Number of Spins of each p-bit
Temperature = data(2);                                     % Temperature, K
save = data(3);                                            % 1: for saving results; 0: no
flag = data(4) - 1;                                        % System to be studied from SIMDAVIS database
starting_mode = data(5);                                   % Starting mode for all spins (0.5 = 50% spins in the lower state of energy)
time_steps = data(6);                                      % Total time steps
constant_or_changeable_magnetic_field = data(7);           % 1: changeable field; 0: constant field 
two_pbits_network = data(8);                               % 1: yes; 0: no for the study of a p-bit network

%###############################################
% CONSTANT MAGNETIC FIELD:
%###############################################
constant_magnetic_field = data(9);                         % Applied magnetic field, Tesla. If only "option" = 0

%###############################################
% CHANGEABLE MAGNETIC FIELD:
%###############################################
maximum_magnetic_field = data(10);                         % Maximum value for Magnetic Field, Tesla. If only "option" = 1
cycles = data(11);                                         % Changeable field applied. If only "option" = 1 

%###############################################
% TWO P-BIT NETWORK:
%###############################################
B_pbit2 = data(12);                                        % Applied magnetic field, Tesla. If only "option_2spin" = 1
threshold_state_definition_pbits = data(13);               % Threshold for the definition of the collective state of each p-bit. If only "option_2spin" = 1
association_factor = data(14);                             % How many delays the program will take into account
step_association = data(15);                               % How many steps of delay the program will take into account to reach the value of the previous variable
B_2pbit =(zeros(1,time_steps));
%-----------------------------------------------------------

%#################################################################
%   Reading the data set:
%#################################################################
[Ueff, tau_0, C, n, tau_QTM, g_Dy, sample_ID] = read_data(flag);

%#################################################################
% Relaxation time of magnetization and other stuff (s):
%#################################################################
[steps, magnetic_relaxation_tau, overall_probability, total_time, time_vector] = simulation_time_setup(Ueff, tau_0, C, n, tau_QTM, Temperature, time_steps);

disp ('**************************************************')
disp ('First p-bit calculations have begun')
disp ('**************************************************')

%#################################################################
% Calculations of single probabilities to spin flipping:
%#################################################################
[magnetic_field_pbit_1, up_probability_pbit_1, down_probability_pbit_1] = applied_magnetic_field(time_steps, ...
                                                                     constant_magnetic_field, ...
                                                                     maximum_magnetic_field, ...
                                                                     cycles, ...
                                                                     constant_or_changeable_magnetic_field, ...
                                                                     Temperature, ...
                                                                     overall_probability,...
                                                                     g_Dy,...
                                                                     0,...
                                                                     0);

%#################################################################
% Calculations of magnetic response in the first p-bit:
%#################################################################
[magnetic_response_pbit_1, magnetic_field_for_second_pbit, spins_up_pbit_1, spins_down_pbit_1, diff_spins_up_down_1, conditional] = simulate_changeable_field(N_ex,...
                                                                                            time_steps,...
                                                                                            up_probability_pbit_1,...
                                                                                            down_probability_pbit_1,...
                                                                                            starting_mode,...
                                                                                            B_pbit2,...
                                                                                            threshold_state_definition_pbits,...
                                                                                            two_pbits_network);
disp ('First p-bit has finished')
disp ('**************************************************')


%#################################################################
%   For a p-bit network:
%#################################################################

if (two_pbits_network == 1)

    disp ('Second p-bit calculations have begun')
    disp ('**************************************************')

    %###########################################################################
    % Calculations of single probabilities to spin flipping on the second p-bit:
    %###########################################################################

    [magnetic_field_pbit_2, up_probability_pbit_2, down_probability_pbit_2] = applied_magnetic_field(time_steps, ...
                                                                         constant_magnetic_field, ...
                                                                         maximum_magnetic_field, ...
                                                                         cycles, ...
                                                                         1, ...
                                                                         Temperature, ...
                                                                         overall_probability,...
                                                                         g_Dy,...
                                                                         1,...
                                                                         magnetic_field_for_second_pbit);

    %###########################################################################
    % Calculations of magnetic response in the second p-bit:
    %###########################################################################
    
    [magnetic_response_pbit_2, magnetic_field_for_third_pbit, spins_up_pbit_2, spins_down_pbit_2, diff_spins_up_down_2, conditional_2] = simulate_changeable_field (N_ex,...
                                                                                                time_steps,...
                                                                                                up_probability_pbit_2,...
                                                                                                down_probability_pbit_2,...
                                                                                                starting_mode,...
                                                                                                B_pbit2,...
                                                                                                threshold_state_definition_pbits,...
                                                                                                1);
    disp ('Second p-bit has finished')
    disp ('**************************************************')
    
    %###########################################################################
    % Setting state of each p-bit:
    %###########################################################################
        
    disp ('Starting association analysis between both p-bits:')
    disp ('**************************************************')

    [V_1_1_t,  V_1_0_t, V_0_1_t, V_0_0_t, phi_t, state_pbit_1, state_pbit_2] = calculating_association (diff_spins_up_down_1, diff_spins_up_down_2, N_ex, time_steps, threshold_state_definition_pbits, association_factor, step_association);

    disp ('Association analysis:')
    disp ('*************************************************')
           
else
    
    B_2 = 0;
    state_pbit_1 = 0;
    state_pbit_2 = 0;
    phi_t = 0;
    magnetic_response_pbit_2 = 0;

end

final = toc;
disp ('Information about the simulation')
disp('*************************************************')
lst_names = {'Compound ID'; 'Spins'; 'Temperature'; 'Relaxation Time'; 'Time step'; 'Steps'; 'Processing time'};
units = {'-'; '-'; 'Kelvin'; 'seconds'; 'seconds'; '-'; 'minutes'};
lst_values = [sample_ID; N_ex; Temperature; magnetic_relaxation_tau; steps; time_steps; final/60];
varNames = {'Feature','Units','Value'};
Results = table(lst_names, units, lst_values, 'VariableNames', varNames);
disp(Results)
disp('*************************************************')

% Save summary to CSV file
filename = sprintf('Simulation_summary_at_%dK.xlsx', Temperature, extension);
writetable(Results, filename);

plotting_results(constant_or_changeable_magnetic_field, N_ex, magnetic_field_pbit_1, magnetic_response_pbit_1, magnetic_response_pbit_2, time_vector, two_pbits_network, Temperature, state_pbit_1, state_pbit_2, phi_t, flag, save);

if (save == 1 && two_pbits_network == 1)   
    print_results(magnetic_response_pbit_2, time_vector(1:length(magnetic_response_pbit_2))', magnetic_field_pbit_2(1:length(magnetic_response_pbit_2))', 2, Temperature);
    print_results(magnetic_response_pbit_1, time_vector(1:length(magnetic_response_pbit_1))', magnetic_field_pbit_1, 1, Temperature);
elseif (save == 1 && two_pbits_network == 0)
    print_results(magnetic_response_pbit_1', time_vector', magnetic_field_pbit_1, 1, Temperature);
end