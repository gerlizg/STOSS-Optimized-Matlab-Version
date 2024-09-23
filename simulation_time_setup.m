function [steps, tau_mag, probability, total_time, time_vector] = simulation_time_setup (Ueff, tau_0, C, n, tau_QTM, T, time_steps)

    %############################################################################
    % Relaxation time of magnetization, (s):
    %############################################################################

    % Precompute frequently used values
    Tn = T^n;
    exp_term = exp(-Ueff/T);
    tau_QTM_inv = 0;
    
    if tau_QTM ~= 0
        tau_QTM_inv = 1/tau_QTM;
    end

    % Compute tau_mag in one step using precomputed values
    % Following relaxation mechanisms: Raman, Orbach, QTM:
    tau_mag = 1 / ((C * Tn) + tau_QTM_inv + (exp_term / tau_0));

    % Calculate total time and steps
    total_time = tau_mag * 20;
    steps = total_time / time_steps;
    
    % Compute probability and time vector
    tau_exp = tau_mag / steps;
    probability = 0;

    for i = 1:25
        temp = 1/((tau_exp^i) * factorial (i));
        if rem(i,2) == 0
            probability = probability - temp;
        else
            probability = probability + temp;
        end
    end
    
    % Use linspace for efficient vector generation
    time_vector = single(linspace(0, total_time, time_steps));
    
end