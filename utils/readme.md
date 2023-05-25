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

`font_gen/bin2memh.py`: Convert font from binary bitmap format (used by VGA BIOS) to a `memh` file. Conversion can only be done on `8*16` fonts. However, you may modify the parameters to suit your need.
