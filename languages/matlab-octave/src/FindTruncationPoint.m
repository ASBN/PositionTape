function position = FindTruncationPoint(receivedText)
    mismatch = FindFirstMismatch(Generate(length(receivedText)), receivedText);
    if isempty(mismatch)
        position = length(receivedText) + 1;
    else
        position = mismatch.position;
    end
end
