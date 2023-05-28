from utils.asm_conv.rawhex2coe import *
from utils.asm_conv.uart_text_gen import *

file_name = input("[Query] file name without (text/data, e.g. video_test) extension: ")
use_empty_data = input("[Query] use empty data?(if not \"y\", then no): ")

target_text_coe = f"./coe/{file_name}_text.coe"
target_data_coe = f"./coe/empty_data.coe"

rawhex2coe(f"./coe/{file_name}_text.raw")
if use_empty_data != "y":
    target_data_coe = f"./coe/{file_name}_data.coe"
    try:
        rawhex2coe(f"./coe/{file_name}_data.raw")
    except FileNotFoundError:
        print("Doesn't exist raw data segment. Skipping generating. ")
        pass
    
print()
uart_text_gen(target_text_coe, target_data_coe, new_file=f"./uart_text/{file_name}.txt")