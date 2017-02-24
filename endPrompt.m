function str = endPrompt()

    prompt = 'Destroy current trial? Y/N [Y]: \n';
    str = input(prompt,'s');
    if isempty(str)
        str = 'Y';
    else

    end
end