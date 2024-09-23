function [V_1_1, V_1_0, V_0_1, V_0_0, association_phi] = getting_association_phi_factor(number, spin_1, spin_2)

    % Slice spin arrays for computation
    spin2 = spin_2(number:end);
    spin1 = spin_1(1:length(spin2));

    % Initialize counts for each state
    V_1_1 = 0;
    V_1_0 = 0;
    V_0_1 = 0;
    V_0_0 = 0;

    % Vectorized counting
    V_0_0 = sum(spin1 == 0 & spin2 == 0);
    V_1_0 = sum(spin1 == 1 & spin2 == 0);
    V_1_1 = sum(spin1 == 1 & spin2 == 1);
    V_0_1 = sum(spin1 == 0 & spin2 == 1);
    
    % Compute association_phi outside of the loop
    N1 = V_1_0 + V_1_1;
    N2 = V_0_0 + V_0_1;
    N3 = V_0_0 + V_1_0;
    N4 = V_0_1 + V_1_1;
    
    % Handle the case when the denominator could be zero to avoid NaN
    denominator = sqrt(N1 * N2 * N3 * N4);
    if denominator == 0
        association_phi = 0;
    else
        association_phi = ((V_0_0 * V_1_1) - (V_0_1 * V_1_0)) / denominator;
    end

end