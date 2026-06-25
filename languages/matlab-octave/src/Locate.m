function position = Locate(fragment)
    if length(fragment) == 0
        position = 1;
        return;
    end

    matches = strfind(Generate(100003), fragment);
    if isempty(matches)
        position = -1;
    else
        position = matches(1);
    end
end
