       IDENTIFICATION DIVISION.
       PROGRAM-ID. SHA256-HYBRID-TESTS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 STATUS-CODE PIC S9(9) COMP-5 VALUE 0.
       01 INPUT-LENGTH PIC S9(9) COMP-5 VALUE 0.
       01 HASH-OUTPUT PIC X(64) VALUE SPACES.
       01 EMPTY-INPUT PIC X(1) VALUE SPACE.
       01 ABC-INPUT PIC X(3) VALUE "abc".
       01 PROJECT-INPUT PIC X(12) VALUE "PositionTape".
       01 FRAGMENT-INPUT PIC X(16) VALUE "3123456789412345".

       PROCEDURE DIVISION.
       MAIN.
           MOVE 0 TO INPUT-LENGTH
           CALL "position_tape_sha256_hex_cobol"
               USING EMPTY-INPUT INPUT-LENGTH HASH-OUTPUT
               RETURNING STATUS-CODE
           IF STATUS-CODE NOT = 1 OR HASH-OUTPUT NOT =
               "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
               DISPLAY "empty sha256 mismatch"
               DISPLAY HASH-OUTPUT
               STOP RUN RETURNING 1
           END-IF

           MOVE 3 TO INPUT-LENGTH
           CALL "position_tape_sha256_hex_cobol"
               USING ABC-INPUT INPUT-LENGTH HASH-OUTPUT
               RETURNING STATUS-CODE
           IF STATUS-CODE NOT = 1 OR HASH-OUTPUT NOT =
               "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
               DISPLAY "abc sha256 mismatch"
               DISPLAY HASH-OUTPUT
               STOP RUN RETURNING 1
           END-IF

           MOVE 12 TO INPUT-LENGTH
           CALL "position_tape_sha256_hex_cobol"
               USING PROJECT-INPUT INPUT-LENGTH HASH-OUTPUT
               RETURNING STATUS-CODE
           IF STATUS-CODE NOT = 1 OR HASH-OUTPUT NOT =
               "55fc0a7c26db83dc2f2aca556e9803ff6d90dcda6c2ad59a69687054ba33abc5"
               DISPLAY "PositionTape sha256 mismatch"
               DISPLAY HASH-OUTPUT
               STOP RUN RETURNING 1
           END-IF

           MOVE 16 TO INPUT-LENGTH
           CALL "position_tape_sha256_hex_cobol"
               USING FRAGMENT-INPUT INPUT-LENGTH HASH-OUTPUT
               RETURNING STATUS-CODE
           IF STATUS-CODE NOT = 1 OR HASH-OUTPUT NOT =
               "babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a"
               DISPLAY "canonical fragment sha256 mismatch"
               DISPLAY HASH-OUTPUT
               STOP RUN RETURNING 1
           END-IF

           DISPLAY "OK cobol sha256 hybrid"
           STOP RUN.
