from position_tape import Generate, GenerateMarkerComplete, Validate


def main() -> None:
    exact = Generate(100)
    marker_complete = GenerateMarkerComplete(1000)
    validation = Validate(exact, 100)

    print(exact)
    print(len(marker_complete))
    print(validation.is_valid)


if __name__ == "__main__":
    main()
