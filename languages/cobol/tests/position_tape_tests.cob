       IDENTIFICATION DIVISION.
       PROGRAM-ID. POSITION-TAPE-TESTS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 REQUESTED-LENGTH        PIC 9(9) COMP VALUE 11.
       01 CURSOR-POSITION         PIC 9(9) COMP VALUE 1.
       01 WRITTEN                 PIC 9(9) COMP VALUE 0.
       01 MARKER-VALUE            PIC 9(9) COMP VALUE 0.
       01 MARKER-TEXT             PIC Z(8)9.
       01 MARKER-CLEAN            PIC X(9).
       01 MARKER-LENGTH           PIC 9(4) COMP VALUE 0.
       01 COPY-LENGTH             PIC 9(4) COMP VALUE 0.
       01 DIGIT-VALUE             PIC 9 COMP VALUE 0.
       01 DIGIT-TEXT              PIC X VALUE SPACE.
       01 OUTPUT-TEXT             PIC X(10003) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN.
           PERFORM GENERATE-TAPE
           IF OUTPUT-TEXT(1:11) NOT = "12345678911"
               DISPLAY "basic generation failed"
               STOP RUN RETURNING 1
           END-IF
           DISPLAY "OK cobol"
           STOP RUN.

       GENERATE-TAPE.
           PERFORM UNTIL WRITTEN >= REQUESTED-LENGTH
               IF FUNCTION MOD(CURSOR-POSITION, 10) = 0
                   COMPUTE MARKER-VALUE = CURSOR-POSITION / 10
                   MOVE MARKER-VALUE TO MARKER-TEXT
                   MOVE FUNCTION TRIM(MARKER-TEXT) TO MARKER-CLEAN
                   MOVE FUNCTION LENGTH(FUNCTION TRIM(MARKER-CLEAN))
                       TO MARKER-LENGTH
                   COMPUTE COPY-LENGTH = REQUESTED-LENGTH - WRITTEN
                   IF COPY-LENGTH > MARKER-LENGTH
                       MOVE MARKER-LENGTH TO COPY-LENGTH
                   END-IF
                   MOVE MARKER-CLEAN(1:COPY-LENGTH)
                       TO OUTPUT-TEXT(WRITTEN + 1:COPY-LENGTH)
                   ADD COPY-LENGTH TO WRITTEN
                   ADD MARKER-LENGTH TO CURSOR-POSITION
               ELSE
                   COMPUTE DIGIT-VALUE = FUNCTION MOD(CURSOR-POSITION, 10)
                   MOVE DIGIT-VALUE TO DIGIT-TEXT
                   ADD 1 TO WRITTEN
                   MOVE DIGIT-TEXT TO OUTPUT-TEXT(WRITTEN:1)
                   ADD 1 TO CURSOR-POSITION
               END-IF
           END-PERFORM.
