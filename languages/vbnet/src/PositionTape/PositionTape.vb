Imports System
Imports System.Collections.Generic
Imports System.Globalization
Imports System.Linq
Imports System.Security.Cryptography
Imports System.Text

Namespace PositionTape
    Public NotInheritable Class Mismatch
        Public Sub New(position As Integer, expected As Char?, received As Char?)
            Me.Position = position
            Me.Expected = expected
            Me.Received = received
        End Sub

        Public ReadOnly Property Position As Integer
        Public ReadOnly Property Expected As Char?
        Public ReadOnly Property Received As Char?
    End Class

    Public NotInheritable Class ValidationResult
        Public Sub New(isValid As Boolean, expectedLength As Integer, receivedLength As Integer, truncationPoint As Integer?, firstMismatch As Mismatch)
            Me.IsValid = isValid
            Me.ExpectedLength = expectedLength
            Me.ReceivedLength = receivedLength
            Me.TruncationPoint = truncationPoint
            Me.FirstMismatch = firstMismatch
        End Sub

        Public ReadOnly Property IsValid As Boolean
        Public ReadOnly Property ExpectedLength As Integer
        Public ReadOnly Property ReceivedLength As Integer
        Public ReadOnly Property TruncationPoint As Integer?
        Public ReadOnly Property FirstMismatch As Mismatch
    End Class

    Public Module Tape
        Public Const DefaultSearchLength As Integer = 100003
        Private ReadOnly IndexCache As New Dictionary(Of Integer, IReadOnlyDictionary(Of String, IReadOnlyList(Of Integer)))()
        Private ReadOnly IndexLock As New Object()

        Public Function Generate(length As Integer) As String
            If length < 0 Then
                Throw New ArgumentOutOfRangeException(NameOf(length), "length must be non-negative")
            End If

            Dim builder As New StringBuilder(length)
            Dim cursor = 1
            While builder.Length < length
                If cursor Mod 10 = 0 Then
                    Dim marker = (cursor \ 10).ToString(CultureInfo.InvariantCulture)
                    Dim remaining = length - builder.Length
                    builder.Append(marker, 0, Math.Min(marker.Length, remaining))
                    cursor += marker.Length
                Else
                    builder.Append(ChrW(AscW("0"c) + (cursor Mod 10)))
                    cursor += 1
                End If
            End While

            Return builder.ToString()
        End Function

        Public Function GenerateMarkerComplete(length As Integer) As String
            Return Generate(GetMarkerCompleteLength(length))
        End Function

        Public Function GetMarkerCompleteLength(length As Integer) As Integer
            If length < 0 Then
                Throw New ArgumentOutOfRangeException(NameOf(length), "length must be non-negative")
            End If

            Dim cursor = 1
            While cursor <= length
                If cursor Mod 10 = 0 Then
                    Dim markerLength = (cursor \ 10).ToString(CultureInfo.InvariantCulture).Length
                    Dim markerEnd = cursor + markerLength - 1
                    If length < markerEnd Then
                        Return markerEnd
                    End If
                    cursor += markerLength
                Else
                    cursor += 1
                End If
            End While

            Return length
        End Function

        Public Function Locate(fragment As String) As Integer
            ArgumentNullException.ThrowIfNull(fragment)
            If fragment.Length = 0 Then
                Return 1
            End If

            Dim index = Generate(DefaultSearchLength).IndexOf(fragment, StringComparison.Ordinal)
            Return If(index < 0, -1, index + 1)
        End Function

        Public Function Validate(receivedText As String, expectedLength As Integer) As ValidationResult
            ArgumentNullException.ThrowIfNull(receivedText)
            Dim expected = Generate(expectedLength)
            Dim mismatch = FindFirstMismatch(expected, receivedText)
            Dim truncationPoint As Integer? = Nothing

            If mismatch IsNot Nothing AndAlso receivedText.Length < expectedLength AndAlso expected.StartsWith(receivedText, StringComparison.Ordinal) Then
                truncationPoint = receivedText.Length + 1
            End If

            Return New ValidationResult(mismatch Is Nothing, expectedLength, receivedText.Length, truncationPoint, mismatch)
        End Function

        Public Function FindTruncationPoint(receivedText As String) As Integer
            ArgumentNullException.ThrowIfNull(receivedText)
            Dim mismatch = FindFirstMismatch(Generate(receivedText.Length), receivedText)
            Return If(mismatch Is Nothing, receivedText.Length + 1, mismatch.Position)
        End Function

        Public Function FindFirstMismatch(expected As String, received As String) As Mismatch
            ArgumentNullException.ThrowIfNull(expected)
            ArgumentNullException.ThrowIfNull(received)

            Dim sharedLength = Math.Min(expected.Length, received.Length)
            For index = 0 To sharedLength - 1
                If expected(index) <> received(index) Then
                    Return New Mismatch(index + 1, expected(index), received(index))
                End If
            Next

            If expected.Length = received.Length Then
                Return Nothing
            End If

            Dim position = sharedLength + 1
            Dim expectedChar As Char? = If(position <= expected.Length, expected(position - 1), CType(Nothing, Char?))
            Dim receivedChar As Char? = If(position <= received.Length, received(position - 1), CType(Nothing, Char?))
            Return New Mismatch(position, expectedChar, receivedChar)
        End Function

        Public Function HashFragment(fragment As String) As String
            ArgumentNullException.ThrowIfNull(fragment)
            Dim hash = SHA256.HashData(Encoding.UTF8.GetBytes(fragment))
            Return Convert.ToHexString(hash).ToLowerInvariant()
        End Function

        Public Function BuildWindowIndex(windowSize As Integer) As IReadOnlyDictionary(Of String, IReadOnlyList(Of Integer))
            If windowSize <= 0 Then
                Throw New ArgumentOutOfRangeException(NameOf(windowSize), "windowSize must be positive")
            End If
            If windowSize > DefaultSearchLength Then
                Throw New ArgumentOutOfRangeException(NameOf(windowSize), "windowSize cannot exceed the default search length")
            End If

            Dim tapeText = Generate(DefaultSearchLength)
            Dim index As New Dictionary(Of String, List(Of Integer))(StringComparer.OrdinalIgnoreCase)
            For offset = 0 To tapeText.Length - windowSize
                Dim hash = HashFragment(tapeText.Substring(offset, windowSize))
                If Not index.ContainsKey(hash) Then
                    index(hash) = New List(Of Integer)()
                End If
                index(hash).Add(offset + 1)
            Next

            Return index.ToDictionary(Function(pair) pair.Key, Function(pair) CType(pair.Value.AsReadOnly(), IReadOnlyList(Of Integer)), StringComparer.OrdinalIgnoreCase)
        End Function

        Public Function LocateByHash(fragmentHash As String, windowSize As Integer) As IReadOnlyList(Of Integer)
            ArgumentNullException.ThrowIfNull(fragmentHash)
            Dim normalizedHash = fragmentHash.Trim().ToLowerInvariant()
            SyncLock IndexLock
                If Not IndexCache.ContainsKey(windowSize) Then
                    IndexCache(windowSize) = BuildWindowIndex(windowSize)
                End If
                Dim positions As IReadOnlyList(Of Integer) = Nothing
                If IndexCache(windowSize).TryGetValue(normalizedHash, positions) Then
                    Return positions
                End If
            End SyncLock

            Return Array.Empty(Of Integer)()
        End Function
    End Module
End Namespace
