import argparse

if __name__ == "__main__":
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "file", help="path to file be parsed. The file must be in bitmap format used by VGA BIOS.", type=str)
    argParser.add_argument(
        "-o", "--output", help="destination file for the coe file. Default to output.txt under cwd in HEX format.", type=str, default="font_out.coe")
    cmd_args = argParser.parse_args()

    file: str = cmd_args.file
    width: int = 8
    height: int = 16
    new_file: str = cmd_args.output
    max_line_cnt: int = 128

    results = []

    with open(file, "rb") as f:
        cnt = 0
        while cnt < max_line_cnt:
            byte_data = f.read(16)
            if not byte_data:
                break

            # reverse byte_data and write
            result = b"".join(reversed(list(map(lambda x: bytearray(int('{:08b}'.format(x)[::-1], 2).to_bytes(1, byteorder='little')), byte_data))))

            results.append(result.hex())
            cnt += 1

    with open(new_file, "w") as f:
        f.write("memory_initialization_radix = 16;\n")
        f.write("memory_initialization_vector =\n")
        f.writelines(',\n'.join(results))

    print(f"Gathered results into: \"{new_file}\" from \"{file}\". Total line cnt: {len(results)}")
