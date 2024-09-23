function [Matrix, magnetic_response] = comparison_states (state_vector, up_probability_pbit_1, down_probability_pbit_1, N_ex, final_step)

    %-------------------------------------------------                
    %   Iteration over the Matrix
    %-------------------------------------------------
    
    Matrix = zeros(N_ex, final_step, 'single');
    Matrix(:, 1) = state_vector;  % Assign the first column to state_vector

    % Vectorized update over all steps
    for i = 2:final_step

        random_numbers = rand(1, N_ex, 'single')';
        
        % Reference to the previous state
        prev_state = Matrix(:, i-1);  

        % Update the state directly using combined logical indexing
        Matrix(:, i) = (prev_state & (random_numbers > up_probability_pbit_1 (i-1))) | (~prev_state & (random_numbers <= down_probability_pbit_1(i-1)));
    
    end

    %-------------------------------------------------
    %   Relaxation curve:
    %-------------------------------------------------
    
    % Calculate the number of spins in state 0 for each time step
    %magnetic_response = single(N_ex - sum(Matrix(:, 1:final_step), 1));
    
    column = sum(Matrix);
    magnetic_response = single(N_ex - column);    
    magnetic_response = magnetic_response(1:final_step);  
    Matrix = Matrix(:,end);
    
    
end

    
        
        

