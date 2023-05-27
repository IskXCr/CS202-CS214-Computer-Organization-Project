import argparse

def rawhex2coe(file, size):
    lines = []
    with open(file, "r") as f:
        lines = f.readlines()
    new_file = file.removesuffix(".asm").removesuffix(".txt").removesuffix(".raw") + ".coe"

    with open(new_file, "w") as f:
        f.write("memory_initialization_radix = 16;\n")
        f.write("memory_initialization_vector =\n")
        lines = list(map(lambda x: x.strip(), lines))[:cmd_args.size]
        cnt = len(lines)
        f.write(',\n'.join(lines))

        if cnt < cmd_args.size:
            f.write(",\n")
            for i in range(cmd_args.size - cnt):
                f.write("00000000,\n")


    print(f'Src: "{file}"\nDst: "{new_file}"')
    print(f'Transformed {cnt} lines.')


if __name__ == "__main__":
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "file", help="path to file be parsed. The file must be dumped out by MARS in \"Hexadecimal Text\" format.", type=str)
    argParser.add_argument(
        "-s", "--size", help="maximum length of the output file in words (32 bit). Default to 16384.", type=int, default=16384)
    cmd_args = argParser.parse_args()
    
    rawhex2coe(cmd_args.file, cmd_args.size)