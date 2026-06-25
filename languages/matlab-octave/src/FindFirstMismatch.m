function mismatch = FindFirstMismatch(expected, received)
    sharedLength = min(length(expected), length(received));

    for index = 1:sharedLength
        if expected(index) ~= received(index)
            mismatch = struct('position', index, 'expected', expected(index), 'received', received(index));
            return;
        end
    end

    if length(expected) == length(received)
        mismatch = [];
        return;
    end

    position = sharedLength + 1;
    expectedChar = [];
    receivedChar = [];
    if position <= length(expected)
        expectedChar = expected(position);
    end
    if position <= length(received)
        receivedChar = received(position);
    end

    mismatch = struct('position', position, 'expected', expectedChar, 'received', receivedChar);
end
