function [magnetic_field, up_probability, down_probability] = applied_magnetic_field(time_steps, ...
                                                                     magnetic_field, ...
                                                                     maximum_magnetic_field, ...
                                                                     cycles, ...
                                                                     constant_or_changeable_magnetic_field, ...
                                                                     Temperature, ...
                                                                     overall_probability,...
                                                                     g_Dy, ...
                                                                     second_pbit_calculation,...
                                                                     magnetic_field_for_second_pbit)

    %############################################################################
    %   Defining the parameters:
    %############################################################################
    
    miu_B = 0.67167;      % Bohr magneton                      
    Mj = 7.5;             % Spin Projection

    %############################################################################    
    %   Calculating probabilities depending on magnetic field:
    %############################################################################
    
    if constant_or_changeable_magnetic_field ~= 0
        magnetic_field = zeros(1, time_steps, 'single');
        Boltzmann_distribution = zeros(1, time_steps, 'single');
        Energy = zeros(1, time_steps, 'single');

        if (second_pbit_calculation == 0)
            % Vectorized calculation for time-dependent magnetic field:
            i = 0:(time_steps-1);
            magnetic_field = maximum_magnetic_field * cos(((pi/2) + (i * cycles * 2 * pi / time_steps)));
        else
            magnetic_field = magnetic_field_for_second_pbit;
        end
    end
    
    % Vectorized calculation for energy gap and Boltzmann distribution:
    Energy = abs(2 * Mj * g_Dy * miu_B * magnetic_field);
    Boltzmann_distribution = 1 ./ exp(Energy / Temperature);

    % Vectorized calculation for probabilities
    down_probability_temp = overall_probability ./ (1 + Boltzmann_distribution);
    up_probability_temp = Boltzmann_distribution .* down_probability_temp;
    
    if constant_or_changeable_magnetic_field ~= 0
        % Condition to swap probabilities based on magnetic field
        negative_field_mask = magnetic_field < 0;
        temp = up_probability_temp(negative_field_mask);
        up_probability_temp(negative_field_mask) = down_probability_temp(negative_field_mask);
        down_probability_temp(negative_field_mask) = temp;

        down_probability = down_probability_temp;
        up_probability = up_probability_temp;

    else
        up_probability = up_probability_temp + zeros(1, time_steps, 'single');
        down_probability = down_probability_temp +  zeros(1, time_steps, 'single');
    end

end