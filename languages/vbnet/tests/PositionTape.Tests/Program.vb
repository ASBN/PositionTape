Imports System
Imports System.IO
Imports System.Security.Cryptography
Imports System.Text.RegularExpressions
Imports PositionTape.PositionTape

Module Program
    Sub Main()
        RequireEqual("", Tape.Generate(0), "Generate(0)")
        RequireEqual("1234567891", Tape.Generate(10), "Generate(10)")
        RequireEqual("12345678911234567892", Tape.Generate(20), "Generate(20)")
        RequireEqual(100, Tape.Generate(100).Length, "Generate(100) length")

        RequireEqual(Tape.Generate(99), Tape.GenerateMarkerComplete(99), "marker complete 99")
        RequireEqual(Tape.Generate(101), Tape.GenerateMarkerComplete(100), "marker complete 100")
        RequireEqual(1002, Tape.GenerateMarkerComplete(1000).Length, "marker complete 1000")
        RequireEqual(10003, Tape.GenerateMarkerComplete(10000).Length, "marker complete 10000")

        Dim expected = Tape.Generate(50)
        Require(Tape.Validate(expected, 50).IsValid, "valid result")
        RequireEqual(18, Tape.Validate(expected.Substring(0, 17), 50).TruncationPoint.Value, "truncation point")
        RequireEqual(4, Tape.FindTruncationPoint("123X"), "mismatch point")
        RequireEqual(13, Tape.FindFirstMismatch(expected, expected.Substring(0, 12) & "X" & expected.Substring(13)).Position, "mismatch")

        Dim fragment = Tape.Generate(80).Substring(29, 12)
        Dim fragmentHash = Tape.HashFragment(fragment)
        RequireEqual(30, Tape.Locate(fragment), "locate")
        Require(Tape.BuildWindowIndex(fragment.Length)(fragmentHash).Contains(30), "hash index")
        Require(Tape.LocateByHash(fragmentHash.ToUpperInvariant(), fragment.Length).Contains(30), "locate by hash")

        Dim root = FindRepositoryRoot()
        Dim manifest = File.ReadAllText(Path.Combine(root, "fixtures", "manifest.generated.json"))
        For Each match As Match In Regex.Matches(manifest, """file"":\s*""([^""]+)"".*?""bytes"":\s*(\d+).*?""sha256"":\s*""([^""]+)""", RegexOptions.Singleline)
            Dim fileName = match.Groups(1).Value
            Dim expectedBytes = Integer.Parse(match.Groups(2).Value)
            Dim expectedSha = match.Groups(3).Value
            Dim raw = File.ReadAllBytes(Path.Combine(root, "fixtures", fileName))

            RequireEqual(expectedBytes, raw.Length, fileName & " bytes")
            RequireEqual(expectedSha, Convert.ToHexString(SHA256.HashData(raw)).ToLowerInvariant(), fileName & " sha256")
            Require(Not (raw.Length >= 3 AndAlso raw(0) = &HEF AndAlso raw(1) = &HBB AndAlso raw(2) = &HBF), fileName & " BOM")
            Require(raw.Length = 0 OrElse (raw(raw.Length - 1) <> AscW(ControlChars.Lf) AndAlso raw(raw.Length - 1) <> AscW(ControlChars.Cr)), fileName & " newline")
        Next

        Console.WriteLine("OK vbnet position_tape")
    End Sub

    Private Sub Require(condition As Boolean, message As String)
        If Not condition Then
            Throw New InvalidOperationException(message)
        End If
    End Sub

    Private Sub RequireEqual(Of T)(expected As T, actual As T, message As String)
        If Not Object.Equals(expected, actual) Then
            Throw New InvalidOperationException($"{message}: got {actual}, want {expected}")
        End If
    End Sub

    Private Function FindRepositoryRoot() As String
        Dim directory As DirectoryInfo = New DirectoryInfo(System.IO.Directory.GetCurrentDirectory())
        While directory IsNot Nothing
            If File.Exists(Path.Combine(directory.FullName, "fixtures", "manifest.generated.json")) Then
                Return directory.FullName
            End If
            directory = directory.Parent
        End While

        Throw New InvalidOperationException("could not find repository root")
    End Function
End Module
