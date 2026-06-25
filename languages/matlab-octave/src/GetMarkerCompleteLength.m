function completeLength = GetMarkerCompleteLength(lengthValue)
    if lengthValue < 0
        error('PositionTape:InvalidLength', 'length must be non-negative');
    end

    cursor = 1;
    while cursor <= lengthValue
        if mod(cursor, 10) == 0
            markerLength = length(num2str(floor(cursor / 10)));
            markerEnd = cursor + markerLength - 1;
            if lengthValue < markerEnd
                completeLength = markerEnd;
                return;
            end
            cursor = cursor + markerLength;
        else
            cursor = cursor + 1;
        end
    end

    completeLength = lengthValue;
end
