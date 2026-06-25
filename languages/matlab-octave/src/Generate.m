function text = Generate(lengthValue)
    if lengthValue < 0
        error('PositionTape:InvalidLength', 'length must be non-negative');
    end

    text = '';
    cursor = 1;
    while length(text) < lengthValue
        if mod(cursor, 10) == 0
            marker = num2str(floor(cursor / 10));
            remaining = lengthValue - length(text);
            text = [text marker(1:min(length(marker), remaining))]; %#ok<AGROW>
            cursor = cursor + length(marker);
        else
            text = [text num2str(mod(cursor, 10))]; %#ok<AGROW>
            cursor = cursor + 1;
        end
    end
end
