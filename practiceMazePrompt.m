function str = practiceMazePrompt()

prompt = 'press any key to start practice maze\n';
str = input(prompt,'s');
if isempty(str)
    str = 'Y';
end

end