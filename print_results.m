function print_results(magnetic_response, time_vector, magnetic_field_original, flag, Temperature)
    
    if flag == 2
        extension = '2.xlsx';
    else
        extension = '1.xlsx';
    end
    
    if (length(magnetic_field_original) == 1)
        magnetic_field = zeros(length(magnetic_response), 1, 'single') + magnetic_field_original;
    else
        magnetic_field = magnetic_field_original;
    end

    varNames = {'Magnetic Response','Time (s)', 'Magnetic Field (T)'};
    results = table([magnetic_response], [time_vector], [magnetic_field], 'VariableNames', varNames);
    
    % Save magnetic response to CSV file
    filename = sprintf('results_summary_at_%dK_pbit_%s', Temperature, extension);
    writetable(results, filename);
   
end