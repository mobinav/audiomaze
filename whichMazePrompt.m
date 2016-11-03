function str = whichMazePrompt()

prompt = 'Enter maze type A-F, or P for practice\n';
str = input(prompt,'s');
if isempty(str)
    str = 'Y';
end

end