function [magnetic_response, magnetic_field_for_other_pbit, spins_up_pbit, spins_down_pbit, diff_spins_up_down, conditional] = simulate_changeable_field (N_ex,...
                                                                                            time_steps,...
                                                                                            up_probability_pbit,...
                                                                                            down_probability_pbit,...
                                                                                            starting_mode,...
                                                                                            B_pbit2,... 
                                                                                            threshold_state_definition_pbits,...
                                                                                            two_pbits_network)
    %############################################################################
    %   Defining the parameters:
    %############################################################################
    conditional = uint8(N_ex/threshold_state_definition_pbits);

    %############################################################################
    %   Creating lists:
    %############################################################################
    state_vector = zeros(N_ex, 1, 'single');                                % Contains all the states (0, 1)  
    spins_up_pbit = zeros(1, time_steps, 'single');                         % Spins in the excited state 
    spins_down_pbit = zeros(1, time_steps, 'single');                       % Spins in the ground state 
    diff_spins_up_down = zeros(1, time_steps, 'single');
    magnetic_field_for_other_pbit = zeros(1,time_steps, 'single');

    % Initializating spins in a specific state:
    if starting_mode ~= 0
        % Use vectorized operation to set the first N_ex * starting_mode elements to 1
        state_vector(1:N_ex * starting_mode) = 1;
    end
    
    % This part is necessary because the size of the matrix
    if (time_steps <= 4500)
        [Matrix, magnetic_response] = comparison_states (state_vector', up_probability_pbit, down_probability_pbit, N_ex, time_steps);
    
    else
        final_step = round (time_steps/3);
        disp ('**************************************************')
        disp("First Part")
        [Matrix_1, magnetic_response_1] = comparison_states (state_vector', up_probability_pbit(1:final_step), down_probability_pbit(1:final_step), N_ex, final_step);      
        disp("Second Part")
        [Matrix_2, magnetic_response_2] = comparison_states (Matrix_1, up_probability_pbit(final_step+1:final_step*2), down_probability_pbit(final_step+1:final_step*2), N_ex, final_step);
        disp("Final Part")
        [Matrix_3, magnetic_response_3] = comparison_states (Matrix_2, up_probability_pbit(final_step*2+1:end), down_probability_pbit(final_step*2+1:end), N_ex, final_step);
                 
        magnetic_response = [magnetic_response_1, magnetic_response_2, magnetic_response_3]';
        
    end
      
    %############################################################################   
    %   IF TWO-PBITS NETWORK:
    %############################################################################
        
   
    if (two_pbits_network == 1)   
        
        for i= 1:time_steps-1
            spins_down_pbit(i) = magnetic_response(i); 
            spins_up_pbit(i) = N_ex - spins_down_pbit(i);
            diff_spins_up_down(i) = spins_up_pbit(i) - spins_down_pbit(i);
            
            if (diff_spins_up_down (i) >= conditional)                           
                magnetic_field_for_other_pbit (i) =  B_pbit2;
            end
                
        end
                   
        mean_value = mean (magnetic_field_for_other_pbit);
        magnetic_field_for_other_pbit = magnetic_field_for_other_pbit - mean_value;
    end
    %{

    if (two_pbits_network == 1)
        % Pre-calculate spins_up_pbit_1 and diff_spins_up_down_1 for all time steps
        spins_down_pbit_1 = magnetic_response_pbit_1(1:time_steps-1);  % Use vectorized assignment
        spins_up_pbit_1 = N_ex - spins_down_pbit_1;                     % Vectorized subtraction
        diff_spins_up_down_1 = spins_up_pbit_1 - spins_down_pbit_1;      % Vectorized difference
    
        % Preallocate magnetic_field_for_second_pbit for performance
        magnetic_field_for_second_pbit = zeros(1, time_steps-1, 'like', B_pbit2);  % Match B_pbit2 type
    
        % Update magnetic field for second pbit where the condition is met (vectorized)
        magnetic_field_for_second_pbit(diff_spins_up_down_1 >= conditional) = B_pbit2;
    
        % Mean subtraction
        mean_value = mean(magnetic_field_for_second_pbit);
        magnetic_field_for_second_pbit = magnetic_field_for_second_pbit - mean_value;
    end
    %}
end
    
