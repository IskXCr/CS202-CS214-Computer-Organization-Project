# Op Table

| Name       | OpCode Hex | Shamt | ALU_Src |
| ---------- | ---------- | ----- | ------- |
| do nothing | 0          |       |         |
| and        | 1          |       |         |
| or         | 2          |       |         |
| xor        | 3          |       |         |
| nor        | 4          |       |         |
| lui        | 5          |       |         |
| ori        | 6          |       |         |
| sll        | 7          |       |         |
| srl        | 8          |       |         |
| sra        | 9          |       |         |
| sllv       | A          |       |         |
| srlv       | B          |       |         |
| srav       | C          |       |         |
| add        | D          |       |         |
| sub        | E          |       |         |
| slt        | F          |       |         |
| sltu       | 10         |       |         |
| MEM        | 11         |       |         |





| Var      | Asserted                            | Not Asserted                                  |
| -------- | ----------------------------------- | --------------------------------------------- |
| op[3]    | use immediate                       |                                               |
| op[2]    |                                     | if use immediate/memory access, do signed-ext |
| funct[0] | do unsigned operation if arithmetic |                                               |
| op[5]    | memory access                       |                                               |
| op[3]    | store                               |                                               |
| op[0]    | halfword                            |                                               |
| op[1]    | word                                |                                               |

