function positions = LocateByHash(fragmentHash, windowSize)
    persistent indexCache;
    if isempty(indexCache)
        indexCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
    end

    cacheKey = num2str(windowSize);
    if ~isKey(indexCache, cacheKey)
        indexCache(cacheKey) = BuildWindowIndex(windowSize);
    end

    index = indexCache(cacheKey);
    hash = lower(strtrim(char(fragmentHash)));
    if isKey(index, hash)
        positions = index(hash);
    else
        positions = [];
    end
end
