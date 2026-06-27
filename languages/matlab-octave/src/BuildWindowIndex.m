function index = BuildWindowIndex(windowSize)
    defaultSearchLength = 100003;
    if windowSize <= 0
        error('PositionTape:InvalidWindowSize', 'windowSize must be positive');
    end
    if windowSize > defaultSearchLength
        error('PositionTape:InvalidWindowSize', 'windowSize cannot exceed the default search length');
    end

    tape = Generate(defaultSearchLength);
    index = containers.Map('KeyType', 'char', 'ValueType', 'any');
    lastStart = length(tape) - windowSize + 1;

    for position = 1:lastStart
        hash = HashFragment(tape(position:position + windowSize - 1));
        if isKey(index, hash)
            index(hash) = [index(hash), position];
        else
            index(hash) = position;
        end
    end
end
