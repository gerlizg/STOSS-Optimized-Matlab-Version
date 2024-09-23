%-------------------------------------------------

function [V_1_1_t,  V_1_0_t, V_0_1_t, V_0_0_t, phi_t, state_1, state_2] = calculating_association (diff_spins_up_down_1, diff_spins_up_down_2, N_ex, time_steps, factor, association_factor, step_association)
    
    %############################################################################    
    % Obtaining the collective behaviour through the threshold
    %############################################################################ 
    
    % Precompute threshold
    threshold = round(N_ex / factor);
    
    % Initialize state with logical values (more efficient for binary data)
    state_1 = false(1, time_steps);
    state_2 = false(1, time_steps);
    
    % Vectorized operation to replace the for-loop
    state_1(diff_spins_up_down_1 >= threshold) = true;
    state_2(diff_spins_up_down_2 >= threshold) = true;

    vector_iter = 1: step_association: association_factor;
    size_vector = length(vector_iter);

    V_1_1_t = single(zeros(1, size_vector));
    V_1_0_t = single(zeros(1, size_vector));
    V_0_1_t = single(zeros(1, size_vector));
    V_0_0_t = single(zeros(1, size_vector));
    phi_t = single(zeros(1, size_vector));
        
    for i = 1: step_association: association_factor
        
        [V_1_1, V_1_0, V_0_1, V_0_0, association_phi] =  getting_association_phi_factor (i, state_1, state_2);
        
        V_1_1_t (i) = V_1_1;
        V_1_0_t (i) = V_1_0;
        V_0_1_t (i) = V_0_1;
        V_0_0_t (i) = V_0_0;
        phi_t (i) = association_phi;
        
    end
    
end
    
    