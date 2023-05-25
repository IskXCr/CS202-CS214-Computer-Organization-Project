import argparse

if __name__ == "__main__":
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "file", help="path to file be parsed. The file must be in bitmap format used by VGA BIOS.", type=str)
    argParser.add_argument(
        "-o", "--output", help="destination file for the `memh` file. Default to output.txt under cwd.", type=str, default="output.memh")
    cmd_args = argParser.parse_args()

    file: str = cmd_args.file
    width: int = 8
    height: int = 16
    new_file: str = cmd_args.output
    max_line_cnt: int = 128

    results = []

    with open(file, "rb") as f:
        byte_data = f.read()
        hex_data = byte_data.hex()
        step = int(width * height / 4)
        print(f"step={step}")
        results = [hex_data[i:i+step] for i in range(0, len(hex_data), step)][0:max_line_cnt]

    with open(new_file, "w") as f:
        results = list(map(lambda x : x + "\n", results))
        f.writelines(results)

    print(f"Gathered results into: \"{new_file}\" from \"{file}\". Total line cnt: {len(results)}")
