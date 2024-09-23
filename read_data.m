function [Ueff, tau_0, C, n, tau_QTM, g_Dy, sample_ID] = read_data (flag)

    %-------------------------------------
    % Getting compound's data:
    %-------------------------------------
    
    filename = 'full_data_file.csv';
    table_0 = readtable(filename);

    data = table2array(table_0 (flag, 3:end));
    Ueff = data (1);
    tau_0 = data (2);
    C = data (3);
    n = data (4);
    tau_QTM = data (5);
    g_Dy = data (6);
    sample_ID = table2array(table_0 (flag, 1));

end