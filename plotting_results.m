function plotting_results(option, N_ex, B_1, y_relaxation_1, y_relaxation_2, time_vector, option_2spin, T, state_1, state_2, phi_t, flag, save_flag)

    % Define colors
    indian_red = "#cd5c5c";    
    teal_color = '#008080';
    dark_blue = "#34495e";
    cinnabar_color = "#e74c3c";

    % Time vector
    x = time_vector;

    % Option 0, single spin system
    if option == 0
        % For single spin without 2-spin option
        if option_2spin == 0
            % Specific temperatures for experimental data comparison
            if ismember(T, [2, 40, 80]) && flag == 23
                filename = sprintf('%dK_exp.csv', T);
                table_0 = readtable(filename);
                x_real = table2array(table_0(:, 1));
                y_real = table2array(table_0(:, 2));

                % Normalize the simulated data to match the real data range
                y = (2 * y_relaxation_1) - N_ex;
                y_relaxation_1 = normalize_to_range(y, y_real);

                % Plot experimental and simulated data
                figure
                plot(x(1:length(y_relaxation_1)), y_relaxation_1, "x", 'LineWidth', 2);
                hold on;
                plot(x_real, y_real, 'LineWidth', 3);
                grid on;
                colororder([indian_red; teal_color])
                legend({"Simulated", "Experimental"}, 'FontSize', 8, 'TextColor', 'black');
                title(generate_plot_title(N_ex, T, B_1(1), 'Constant Field', 0));
            else
                % Plot only the simulated data
                plot(x(1:length(y_relaxation_1)), y_relaxation_1, 'Color', teal_color, 'LineWidth', 3);
                legend("Simulated");
                grid on;
                title(generate_plot_title(N_ex, T, B_1(1), 'Constant Field', 0));
            end
        % For two-spin system
        else
            plot_two_spin_system(x, state_1, state_2, phi_t, y_relaxation_1, y_relaxation_2, T, cinnabar_color, dark_blue, teal_color);
        end

    % Option 1, changing field system
    elseif option == 1
        colororder([indian_red; teal_color])
        yyaxis left
        ylim([N_ex*0.4, N_ex*0.6])
        plot(x(1:length(y_relaxation_1)), y_relaxation_1, 'LineWidth', 3)
        ylabel('mu, (a.u.)')

        yyaxis right
        ylim([N_ex*0.4, N_ex*0.6])
        plot(x(1:length(y_relaxation_1)), B_1 * -1000, "--", 'LineWidth', 1.5)
        grid on
        legend({"Simulated response", "AC field"}, 'FontSize', 8, 'TextColor', 'black');
        title(generate_plot_title(N_ex, T, 0,'Changeable Field', 1));
        ylabel('Magnetic Field (mT)')
    end

    % Save the plot if the save flag is set
    if save_flag
        save_plot(T, option_2spin);
    end
end

% Helper function to normalize the simulated data to the real data range
function y_normalized = normalize_to_range(y, y_real)
    rmin = min(y);
    rmax = max(y);
    tmin = min(y_real);
    tmax = max(y_real);
    y_normalized = (((y - rmin) / (rmax - rmin)) * (tmax - tmin)) + tmin;
end

% Helper function to generate plot titles
function plot_title = generate_plot_title(N_ex, T, B_field, field_type, flag_type)
    if (flag_type == 0)
        plot_title = sprintf('%d spins at %.2fK (%s: %.1fT)', N_ex, T, field_type, B_field);
    else 
        plot_title = sprintf('%d spins at %.2fK (%s)', N_ex, T, field_type);
    end
end

% Helper function to plot the two-spin system
function plot_two_spin_system(x, state_1, state_2, phi_t, y_relaxation_1, y_relaxation_2, T, cinnabar_color, dark_blue, teal_color)
    tiledlayout(3, 1);

    % Top plot
    nexttile;
    plot(x(1:length(state_1)), state_1, 'LineWidth', 2);
    hold on;
    plot(x(1:length(state_2)), state_2, 'LineWidth', 2);
    colororder([cinnabar_color; dark_blue]);
    legend({"p-bit i", "p-bit j"}, 'FontSize', 8, 'TextColor', 'black', 'Location', 'northoutside', 'Orientation', 'horizontal');
    ylabel('State');
    grid on;

    % Middle plot (phi_t)
    nexttile;
    plot(x(1:length(phi_t)), phi_t, 'LineWidth', 2, 'Color', teal_color);
    ylabel('\Phi');
    grid on;

    % Bottom plot (y relaxation)
    nexttile;
    plot(x(1:length(y_relaxation_1)), y_relaxation_1, 'LineWidth', 2);
    hold on;
    plot(x(1:length(y_relaxation_1)), y_relaxation_2, 'LineWidth', 2);
    colororder([cinnabar_color; dark_blue]);
    xlabel('Time (ms)');
    ylabel('mu (a.u.)');
    grid on;
end

% Helper function to save plots with appropriate names
function save_plot(T, option_2spin)
    if option_2spin == 1
        filename = sprintf('two_p_bits_network_%dK.png', T);
    else
        filename = sprintf('Relaxation_%dK_exp.png', T);
    end
    saveas(gcf, filename);
end