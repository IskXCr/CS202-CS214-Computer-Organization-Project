# Introduction to Utilities

- for usages of those utilities, please: 
  - run with `-h` option if it is written in Python and with source code
  - or refer to official document.


## ASCII Art Generator

Please refer to [ascgen2's official website](http://sourceforge.net/projects/ascgen2/) to get the executable.

## ASM -> COE/UART Data Conversion

`asm_conv/rawhex2coe.py`: Generate COE file from raw file produced by MARS (dump to ...)

`asm_conv/uart_text_gen.py`: Generate UART text file by combining two COE files (text/data) produced by `rawhex2coe.py`.

## Font Generator

`font_gen/bin2coe.py`: Convert font from binary bitmap format (used by VGA BIOS) to a `coe` file loaded into a block memory generator. Currently, conversion can only be done on `8*16` fonts. However, you may modify the parameters to suit your need.

## Video Encoder

`savf_conv/savf_encoder`: Convert an ASCII video into a byte stream encoded using Huffman code.
