package main

import (
	"fmt"

	pt "github.com/positiontape/positiontape/languages/go/src/positiontape"
)

func main() {
	tape, err := pt.Generate(101)
	if err != nil {
		panic(err)
	}
	fmt.Println(tape)
}
