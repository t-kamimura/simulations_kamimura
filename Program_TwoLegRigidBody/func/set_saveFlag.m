function saveFlag = set_saveFlag(defaultAns)

    % Construct a questdlg with three options
    choice = questdlg('Do you want to save the result(s)?', ...
    'Saving opptions', ...
    'Yes', 'No', defaultAns);

    % Handle response
    saveFlag = false;

    switch choice
    case 'Yes'
        saveFlag = true;
    case 'No'
        saveFlag = false;
    end

end