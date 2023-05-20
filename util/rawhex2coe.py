import argparse

if __name__ == "__main__":
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "file", help="path to file be parsed. The file must be dumped out by MARS in \"Hexadecimal Text\" format.", type=str)
    argParser.add_argument(
        "-s", "--size", help="maximum size of the output file in bytes", type=int, default=16384)
    cmd_args = argParser.parse_args()

    file: str = cmd_args.file
    
    lines = []
    with open(file, "r") as f:
        lines = f.readlines()
    new_file = file.removesuffix(".asm").removesuffix(".txt").removesuffix(".raw") + ".coe"
    with open(new_file, "w") as f:
        f.write("memory_initialization_radix = 16;\n")
        f.write("memory_initialization_vector =\n")
        cnt = 0
        for line in lines:
            cnt += 1
            if cnt > cmd_args.size:
                break
            f.write(line.strip() + ",\n")

    print(f'Src: "{file}"\nDst: "{new_file}"')
    print(f'Transformed {len(lines)} lines.')