#include "../src/position_tape.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char *exact = position_tape_generate(100);
    char *marker_complete = position_tape_generate_marker_complete(1000);
    PositionTapeValidationResult validation = position_tape_validate(exact, 100);

    printf("%s\n", exact);
    printf("%zu\n", strlen(marker_complete));
    printf("%s\n", validation.is_valid ? "true" : "false");

    free(exact);
    free(marker_complete);
    return 0;
}
