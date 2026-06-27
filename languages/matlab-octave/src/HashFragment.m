function hash = HashFragment(fragment)
    fragment = char(fragment);

    if exist('hash', 'builtin') || exist('hash', 'file')
        hash = lower(hash('sha256', fragment));
        return;
    end

    if exist('javaMethod', 'builtin') || exist('javaMethod', 'file')
        try
            digest = javaMethod('getInstance', 'java.security.MessageDigest', 'SHA-256');
            bytes = uint8(fragment);
            digest.update(bytes);
            hashBytes = typecast(digest.digest(), 'uint8');
            hash = lower(reshape(dec2hex(hashBytes, 2).', 1, []));
            return;
        catch
        end
    end

    inputFile = [tempname(), '.txt'];
    fid = fopen(inputFile, 'w');
    cleanup = onCleanup(@() deleteIfExists(inputFile));
    fwrite(fid, uint8(fragment), 'uint8');
    fclose(fid);

    [status, output] = system(['shasum -a 256 "', inputFile, '"']);
    if status == 0
        parts = strsplit(strtrim(output));
        hash = lower(parts{1});
        return;
    end

    [status, output] = system(['openssl dgst -sha256 -r "', inputFile, '"']);
    if status == 0
        parts = strsplit(strtrim(output));
        hash = lower(parts{1});
        return;
    end

    error('PositionTape:HashUnavailable', ...
        'SHA-256 is unavailable; use Octave hash(), MATLAB Java, shasum, or openssl.');
end

function deleteIfExists(path)
    if exist(path, 'file')
        delete(path);
    end
end
