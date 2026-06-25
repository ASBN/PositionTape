Imports System
Imports PositionTape.PositionTape

Module Program
    Sub Main()
        Dim exact = Tape.Generate(100)
        Dim markerComplete = Tape.GenerateMarkerComplete(1000)
        Dim validation = Tape.Validate(exact, 100)

        Console.WriteLine(exact)
        Console.WriteLine(markerComplete.Length)
        Console.WriteLine(validation.IsValid)
    End Sub
End Module
