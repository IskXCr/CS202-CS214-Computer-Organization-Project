'''
This utlity package is designed to encode a series of ASCII frames into SAVF format.
that can be later interpreted using symbol mapping in MARS and in MIPS processors (which implies everything is little-endian).

Several functions are exposed as APIs so that these utilities can be directly called from other files.

For further information, refer to the document.
'''

import argparse
import natsort
import glob
import numpy as np
import copy
import itertools
import time
import sys
import os


class SAVF_Map_Entry:
    '''
    An entry object that records the differences of a delta frame with respect to its reference 
    frame.

    This entry has a built-in ```hex()``` method to help get it transformed into a coe file
    '''
    def __init__(self, y_pos: int, x_pos: int, target: int):
        self.y_pos = y_pos
        self.x_pos = x_pos
        self.target = target
        if y_pos > 32:
            raise ValueError

    
    def __repr__(self) -> str:
        return f"<SAVF_Map_Entry, y={self.y_pos}, x={self.x_pos}, target={self.target}>"
    

    def hex(self) -> str:
        res = int(format(self.y_pos, "06b") + format(self.x_pos, "06b") + format(self.target, "04b"), 2)
        hex_str = format(res, "04x")
        return hex_str


    def __eq__(self, __value: object) -> bool:
        if isinstance(__value, SAVF_Map_Entry):
            return __value.y_pos == self.y_pos and __value.x_pos == self.x_pos and __value.target == self.target
        else:
            return False


class SAVF_Frame:
    '''
    A frame object that records the essential information of this frame, 
    including the matrix of characters.

    Throughout the processing of the entire video, this frame may be assigned a property 
    such as "K" which represents a Key Frame and "D" which represents a Delta Frame.

    For specification, please refer to the document.
    '''
    def __init__(self, width: int = 40, height: int = 16) -> None:
        self.f_type = "K"
        self.width = width
        self.height = height
        self.cmap = np.zeros((height, width), dtype=int) # character map
        self.entries: list[SAVF_Map_Entry] = []
        self.last_frame = False


    def copy(self):
        other = SAVF_Frame(self.width, self.height)
        other.f_type = self.f_type
        other.cmap = self.cmap.copy()
        other.entries = copy.deepcopy(self.entries)

        return other
    

    def __repr__(self) -> str:
        size = (self.width * self.height / 0.5) if self.f_type == "K" else (len(self.entries) * 2 + (0 if len(self.entries) % 2 == 1 else 2))
        return f"<Type {self.f_type} Frame, #delta_entries={len(self.entries)}, width={self.width}, height={self.height}, size={size} bytes>"


    def __eq__(self, __value: object) -> bool:
        if isinstance(__value, SAVF_Frame):
            return __value.f_type == self.f_type and __value.entries == self.entries and np.array_equiv(__value.cmap, self.cmap)
        else:
            return False


class SAVF_Converter:
    def __init__(self, width: int = 40, height: int = 16) -> None:
        self.mapping = {' ': 0, 'M': 1, '@': 2, 'W': 3, '0': 4, '8': 5, 'Z': 6, 'a': 7, '2': 8, 'S': 9, '7': 0xA, 'r': 0xB, 'i': 0xC, ':': 0xD, ';': 0xE, '.': 0xF}
        self.reversed_mapping = {val: key for key, val in self.mapping.items()}
        self.frame_list = []
        self.result_list = []
        self.width = width
        self.height = height


    def read_ascii_frame(self, filename: str):
        '''
        Read a single ASCII frame from a file and transform it into a frame object
        '''
        content = []
        with open(filename, "r") as f:
            content = f.readlines()
        content = "".join(content).replace("\r", "").replace("\n", "")

        frame = SAVF_Frame(self.width, self.height)
        for i in range(self.height):
            for j in range(self.width):
                frame.cmap[i, j] = self.mapping[content[i * self.width + j]]

        return frame

    
    def read_ascii_frames(self, file_pattern: int):
        '''
        Read the ASCII frame stream from a sequence of files.

        Return a list of read frames. A marker frame will be appended to the end to indicate termination.

        :param: file_pattern: the pattern of file used by ```glob``` utility
        '''
        matched_files = glob.glob(file_pattern)
        matched_files = natsort.natsorted(matched_files)
        cnt = len(matched_files)

        frames = []

        for file_path in matched_files:
            frames.append(self.read_ascii_frame(file_path))

        last_frame = SAVF_Frame(self.width, self.height)
        last_frame.last_frame = True
        frames.append(last_frame)

        return frames


    def key2ascii(self, frame: SAVF_Frame):
        '''
        Convert a KEY frame into ASCII art, including linefeed.
        '''
        assert frame.f_type == "K", "Input key frame for conversion to ASCII frame must be a key frame."

        result = ""
        for i in range(self.height):
            for j in range(self.width):
                result += self.reversed_mapping[frame.cmap[i, j]]
            result += "\n"

        result = result + "\n"
        return result


    def keys2ascii(self, frames):
        '''
        Convert a sequence of SAVF_Frame objects with type K into ASCII stream.
        '''
        return list(map(self.key2ascii, frames))

    
    def calc_diff(self, frame1: SAVF_Frame, frame2: SAVF_Frame):
        '''
        Calculate the difference between two frames
        Return a list of indices that marks the difference between two frames
        '''
        indices = np.nonzero(frame1.cmap != frame2.cmap)
        return indices


    def cost_to_delta(self, ref: SAVF_Frame, frame: SAVF_Frame):
        '''
        Calculate the cost associated with transforming the input key frame into a delta frame. 
        
        A positive cost indicates an increase in file size due to this transformation.

        Costs are in unit of 4-bits.
        '''
        diff = self.calc_diff(ref, frame)
        cnt = diff[0].shape[0]
        
        cost_delta = 4 + cnt * 4 + (0 if cnt % 2 == 1 else 4)
        cost_key = 8 + ref.width * ref.height
        return cost_delta - cost_key

    
    def key2delta(self, ref: SAVF_Frame, frame: SAVF_Frame):
        '''
        Given a reference frame, transform a key frame into a delta frame.
        
        The original frame won't be modified.

        If the frame isn't a key frame, do nothing.

        :param: ref: reference frame
        '''
        if frame.f_type != "K":
            return frame.copy()

        result = SAVF_Frame(self.width, self.height)
        result.f_type = "D"
        
        diff = self.calc_diff(ref, frame)
        elements = frame.cmap[diff]
        params = zip(diff[0], diff[1], elements)
        result.entries = list(map(lambda x: SAVF_Map_Entry(x[0], x[1], x[2]), params))
        
        return result


    def delta2key(self, ref: SAVF_Frame, delta: SAVF_Frame):
        '''
        Convert a delta frame to a key frame based on the reference frame.

        If the source frame isn't a delta frame, do nothing.
        '''
        if delta.f_type != "D":
            return frame.copy()

        frame = ref.copy()
        for entry in delta.entries:
            frame.cmap[(entry.y_pos, entry.x_pos)] = entry.target
        
        return frame


    def key2hex(self, frame: SAVF_Frame):
        '''
        Transform a delta frame into its hexadecimal representation in little-endian, aligned on a 32-bit boundary.

        The default behavior of this function is to concatenate all entries and pad the end with zeros.
        '''
        if frame.last_frame:
            return "ffffffff"

        result = "80000000"
        
        cnt = 0
        prev = None
        comb_list = []

        for i in np.nditer(frame.cmap):
            cnt += 1
            if cnt % 2 == 0:
                comb_list.append(format(int(format(i, "01x") + format(prev, "01x"), 16), "02x"))
            if cnt % 8 == 0:
                for entry in reversed(comb_list):
                    result += entry
                comb_list.clear()
            prev = i
        
        if cnt % 2 != 0:
            comb_list.append(format(int("0" + format(prev, "01x"), 16), "02x"))
        
        while len(comb_list) < 4:
            comb_list.append("00")

        if cnt % 8 != 0:
            for entry in reversed(comb_list):
                result += entry

        return result


    def delta2hex(self, frame: SAVF_Frame):
        '''
        Transform a delta frame into its hexadecimal representation in little-endian, aligned on a 32-bit boundary.
        '''
        result = format(int("0" + format(len(frame.entries), "015b"), 2), "04x")
        if len(frame.entries) == 0:
            result += "0000"
            return result
        
        result += frame.entries[0].hex()

        cnt = 0
        prev = None
        for i in range(1, len(frame.entries)):
            entry = frame.entries[i]
            cnt += 1
            if cnt % 2 == 0:
                result += entry.hex() + prev.hex()
            prev = entry
        
        if cnt % 2 != 0:
            result += "0000" + prev.hex()
        
        return result


    def frame2hex(self, frame: SAVF_Frame):
        '''
        Transform a frame object into its hexadecimal representation in little-endian
        '''
        result = None

        if frame.f_type == "K":
            result = self.key2hex(frame)
        elif frame.f_type == "D":
            result = self.delta2hex(frame)
        
        return result


    def frames2hex(self, frames: list[SAVF_Frame], sep: bool = False):
        '''
        Transform a sequence of frames into a hex string.
        '''
        result = ""
        for frame in frames:
            result += self.frame2hex(frame) + ("\n" if sep else "")

        return result
    

    def compress(self, frames: list[SAVF_Frame]):
        '''
        Encode a list of **key** frames into a list of mixed frames for playing.

        Encoding will end when the first marker frame for termination is encountered.

        The original frame list will not be changed, and so do the frames within.
        '''

        if len(frames) < 1:
            results = copy.deepcopy(frames)
            return results

        ref_frame: SAVF_Frame = frames[0].copy()
        results = [ref_frame]
        
        for i in range(1, len(frames)):
            frame = frames[i]
            if frame.last_frame:
                results.append(frame.copy())
                break
            if self.cost_to_delta(ref_frame, frame) < 0:
                delta = self.key2delta(ref_frame, frame)
                ref_frame = frame
                results.append(delta)
            else:
                ref_frame = frame
                results.append(frame.copy())
        
        return results


    def hex2key(self, hex_str: str):
        '''
        Parse a hexadecimal string into a key frame. Assume aligned on a 32-bit boundary.
        '''
        assert len(hex_str) != 0, "Empty key hex string."

        frame = SAVF_Frame(self.width, self.height)

        if int(hex_str[:8], 16) == 0xffffffff:
            frame.last_frame = True
            return frame

        hex_str = hex_str[8:]
        tokens_32 = [hex_str[i:i+8] for i in range(0, len(hex_str), 8)]
        tokens = list(map(lambda x: int(x, 16), itertools.chain(*[token for token_str in tokens_32 for token in reversed(token_str)])))

        frame.cmap = np.array(tokens).reshape((self.height, self.width))

        return frame


    def hex2delta(self, hex_str: str):
        '''
        Transform a hexadecimal string into a delta frame. Assume aligned on a 32-bit boundary.
        '''
        assert len(hex_str) != 0, "Empty delta hex string."
        size = int(hex_str[:4], 16)

        frame = SAVF_Frame(self.width, self.height)
        frame.f_type = "D"

        tokens_16 = [hex_str[i:i+8] for i in range(0, len(hex_str), 8)]
        tokens = list(itertools.chain(*[[token[4:8], token[0:4]] for token in tokens_16]))
        if len(tokens) > 1:
            del tokens[1]

        if len(tokens) != size and len(tokens) != size + 1:
            print([[token[4:8], token[0:4]] for token in tokens_16])
            print(tokens)
            print(len(tokens))
            print(size)
            raise ValueError

        cnt = 0
        for token in tokens:
            cnt += 1
            bin_str = format(int(token, 16), "016b")
            if cnt > size:
                continue
            y_pos = int(bin_str[:6], 2)
            x_pos = int(bin_str[6:12], 2)
            change = int(bin_str[12:16], 2)
            entry = SAVF_Map_Entry(y_pos, x_pos, change)
            frame.entries.append(entry)
        
        return frame


    def parse(self, hex_str: str, verbose: int = 0):
        '''
        Parse a VALID hexadecimal string and try to recover a series of mixed frames.

        The string must be VALID or undefined behavior may occur inside the parser FSM.
        '''
        frames = []
        key_frame_size = self.width * self.height

        idx = 0
        while idx < len(hex_str):
            if verbose > 0:
                print(f"[Parser] Parsing frame {len(frames)}, hex_idx={idx}")
            # parse the header
            header = int(hex_str[idx:idx+8], 16)
            if header > 0x7fffffff:
                # Key Frame
                if verbose > 0:
                    print(f"[Parser][Key] Parsing frame segment starting from {idx} to {idx+key_frame_size+8}, size={key_frame_size}")
                frames.append(self.hex2key(hex_str[idx:idx+key_frame_size + 8]))
                idx += key_frame_size + 8
            else:
                # Delta Frame
                delta_frame_size = int(hex_str[idx:idx+4], 16) * 4
                if delta_frame_size % 8 == 0:
                    delta_frame_size += 4
                if delta_frame_size > 640:
                    print(f"[Parser] Invalid size at idx {idx}: {delta_frame_size}. Parsed header = {hex_str[idx:idx+4]}")
                    sys.exit(1)
                if verbose > 0:
                    print(f"[Parser][Delta] Parsing frame segment starting from {idx} to {idx+delta_frame_size+4}, size={delta_frame_size}")
                frames.append(self.hex2delta(hex_str[idx:idx+delta_frame_size + 4]))
                idx += delta_frame_size + 4
        
        return frames


    def hex2frames(self, hex_str: str, verbose: int = 0):
        '''
        Convert a hexadecimal stream of SAVF video into mixed frames.
        '''
        return self.parse(hex_str, verbose)


    def all_to_key_frames(self, frames: list[SAVF_Frame]):
        '''
        Convert all frames into key frames.
        '''
        if len(frames) < 1:
            results = copy.deepcopy(frames)
            return results

        ref_frame: SAVF_Frame = frames[0].copy()
        results = [ref_frame]
        
        for i in range(1, len(frames)):
            frame = frames[i]
            if frame.last_frame:
                results.append(frame.copy())
                break
            if frame.f_type == "D":
                new_key = self.delta2key(ref_frame, frame)
                ref_frame = new_key
                results.append(new_key)
            else:
                ref_frame = frame
                results.append(frame.copy())
        
        return results


    def frames2coe(self, frames: list[SAVF_Frame], vector_size: int = 8):
        '''
        Transform a sequence of frames into a valid coe string.
        '''
        result = "memory_initialization_radix = 16;\n"
        result += "memory_initialization_vector =\n"

        hex_str = self.frames2hex(frames)
        substrings = [hex_str[i:i+vector_size] for i in range(0, len(hex_str), vector_size)]
        if len(substrings[-1]) < vector_size:
            substrings[-1] = "".join(["0" for _ in range(vector_size - len(substrings[-1]))]) + substrings[-1]

        result += "\n".join(substrings)

        print(f"[frames2coe] {len(substrings)} vectors written. ")
        return result


    def play_at_console(self, frames: list[SAVF_Frame], spf: float = 0.03333333, prefetch: bool = False) -> None:
        '''
        Play the frame stream at console.

        :param: spf: second per frame
        '''
        # https://stackoverflow.com/questions/2726343/how-to-create-ascii-animation-in-a-console-application-using-python-3-x
        clear_console = 'clear' if os.name == 'posix' else 'CLS'

        # https://stackoverflow.com/a/40755193
        def cls(n: int):
            '''
            :param: n: number of rows written
            '''
            if n == 0:
                os.system(clear_console)
            else:
                print("\033[F" * n)

        cls(0)

        if prefetch:
            frames = self.all_to_key_frames(frames)
            vals = self.keys2ascii(frames)

            start = time.perf_counter()
            for i in range(len(frames)):
                frame = frames[i]
                if frame.last_frame:
                    sys.stdout.write("TERMINATED.")
                    sys.stdout.flush()
                else:
                    val = vals[i]
                    info1 = f"frame: {i}, \ttime: {i / 30} s          "
                    info2 = f"original_info: {frame}          "
                    cls(self.height + 5)
                    # starting 1 line
                    print(val)   # {self.height + 1} lines
                    print(info1) # 1 line
                    print(info2) # 1 line + ending 1 line
                    current_time = time.perf_counter()
                    sleep_time = max(start + i * spf - current_time, 0)
                    time.sleep(sleep_time)

        else:
            ref_frame = None

            start = time.perf_counter()
            for i in range(len(frames)):
                frame = frames[i]
                if frame.last_frame:
                    sys.stdout.write("TERMINATED.")
                    sys.stdout.flush()
                else:
                    frame0 = frame
                    if frame.f_type == "D":
                        frame0 = self.delta2key(ref_frame, frame)
                    elif frame.f_type == "K":
                        pass
                    cls(self.height + 5)
                    sys.stdout.write(self.key2ascii(frame0))
                    sys.stdout.write(f"frame: {i}, \ttime: {i / 30} s\n")
                    sys.stdout.write(f"key_info: {frame0}\n")
                    sys.stdout.write(f"original_info: {frame}\n")
                    sys.stdout.flush()
                    ref_frame = frame0
                    
                    current_time = time.perf_counter()
                    sleep_time = max(start + i * spf - current_time, 0)
                    time.sleep(sleep_time)


    def verify(self, src0: list[SAVF_Frame], dst0: list[SAVF_Frame]):
        '''
        Verify whether two sequences of frames are the same.
        
        Two new sequences will be created in which delta frames are transformed to key frames.

        If prefetch, the converter tries to acquire all key frames before playing, which will result in loss of the original
        frame info.
        '''
        assert len(src0) == len(dst0), "Verification: different stream length"
        src = self.all_to_key_frames(src0)
        dst = self.all_to_key_frames(dst0)

        for i in range(len(src)):
            try:
                frame1 = src[i]
                frame2 = dst[i]
                assert frame1 == frame2, "Verification: different frame value."
            except AssertionError:
                print(f"[Verification] Frame difference encountered at position {i}")
                print("==========Source=========")
                print(frame1)
                print(self.key2ascii(frame1))
                print("=======Destination=======")
                print(frame2)
                print(self.key2ascii(frame2))

                print()
                print("Difference Map: ")
                mp1 = np.nonzero(frame1.cmap != frame2.cmap)
                mp1 = list(zip(mp1[0], mp1[1]))
                print(mp1)

                print()
                print("Original information: ")
                print(src0[i])
                print(dst0[i])

                sys.exit(1)

        print(f"[Verification] Completed verfication without errors")



def simple_test():
    converter = SAVF_Converter()
    frame1 = converter.read_ascii_frame("./stream_40x16/ASCII-out3644.txt")
    frame2 = converter.read_ascii_frame("./stream_40x16/ASCII-out3645.txt")
    delta = converter.key2delta(frame1, frame2)
    print(delta.entries)
    print(len(delta.entries))

    entry: SAVF_Map_Entry = delta.entries[-1]
    print(entry)
    print(entry.hex())
    hex_str = converter.key2hex(frame1)
    print(hex_str)
    print()
    
    hex_str2 = converter.delta2hex(delta)
    print(hex_str2)
    print(len(converter.frames2hex([frame1])) / 2)


def savf_conv(file_pattern: str, output):
    '''
    Main conversion function. Accepts a file_pattern to search for files and an output path. 

    Generate a ```coe``` file specified in the output path.
    '''
    converter = SAVF_Converter()

    frames = converter.read_ascii_frames(file_pattern)
    print("Read completed.")

    compressed = converter.compress(frames)
    print("Compression completed.")

    encoded = converter.frames2hex(compressed)
    print("Encoding completed.")

    print(f"Encoded length: {len(encoded)}, {len(encoded) / 2} bytes in total")

    with open(output, "w") as f:
        f.writelines(converter.frames2coe(compressed))

    print(f"COE output written to {output}")

    # with open("encoded.txt", "w") as f:
    #     f.writelines(encoded)
    
    # with open("frame_info.txt", "w") as f:
    #     for frame in compressed:
    #         f.write(frame.__repr__())
    #         f.write("\n")

    decoded = converter.hex2frames(encoded.replace("\n", "").replace("\r", ""))
    print("Decoding completed.")

    print("Comparing compressed with original.")
    converter.verify(frames, compressed)

    print("Comparing decoded with original.")
    converter.verify(frames, decoded)

    input("Press any key to start playing...")

    spf = float(input("Second per frame: "))

    prefetch = input("Prefetch? (Y/n) ")
    if prefetch == "Y" or prefetch == "y":
        prefetch = True
    else:
        prefetch = False

    converter.play_at_console(decoded, spf, prefetch)


if __name__ == "__main__":
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "file_pattern", help="file pattern used to collect ASCII frames", type=str)
    argParser.add_argument(
        "-o", "--output", help="path to output coe file.", type=str, default="output.coe")
    cmd_args = argParser.parse_args()

    savf_conv(cmd_args.file_pattern, cmd_args.output)