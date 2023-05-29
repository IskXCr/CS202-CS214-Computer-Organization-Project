module keyboard (
  input           clk,
  input           rst,
  input      [3:0] row,
  output reg [3:0] col,
  output reg [3:0] keyboard_val,
  output reg      press,
  output reg [7:0] wdata
);

  reg [19:0] cnt;
  wire       key_clk;
  reg [7:0] state;
  reg start;
  reg [3:0] idle;

  always @(posedge clk or posedge rst) begin
    if (rst)
      cnt <= 0;
    else
      cnt <= cnt + 1'b1;
  end

  assign key_clk = cnt[19];
  
  always @(posedge key_clk or posedge rst) begin
    if (rst) begin
        col <= 4'b0001;
        idle <= 4'b1111;
    end
    else if (col == 4'b1000) col <= 4'b0001;
    else if (col == 4'b0000) col <= 4'b0001;
    else col <= col << 1;
  end

  always @(posedge key_clk or posedge rst) begin
    if (rst) begin
      keyboard_val <= 4'b0000;
      press <= 0;
    end else begin
                  if (row != 4'hF) begin
                    case ({col, row})
                       {4'b0001, 4'b1110}: keyboard_val <= 4'b0001;//1
                          {4'b0001, 4'b1101}: keyboard_val <= 4'b0100;//4
                                {4'b0001, 4'b1011}: keyboard_val <= 4'b0111;//7
                                    {4'b0001, 4'b0111}: keyboard_val <= 4'b1110;//*               
                                                             {4'b0010, 4'b1110}: keyboard_val <= 4'b0010;//2
                                                             {4'b0010, 4'b1101}: keyboard_val <= 4'b0101;//5
                                                             {4'b0010, 4'b1011}: keyboard_val <= 4'b1000;//8
                                                             {4'b0010, 4'b0111}: keyboard_val <= 4'b0000;//0
                                       
                                                             {4'b0100, 4'b1110}: keyboard_val <= 4'b0011;//3
                                                             {4'b0100, 4'b1101}: keyboard_val <= 4'b0110;//6
                                                             {4'b0100, 4'b1011}: keyboard_val <= 4'b1001;//9
                                                             {4'b0100, 4'b0111}: keyboard_val <= 4'b1111;//#
                                       
                                                             {4'b1000, 4'b1110}: keyboard_val <= 4'b1010;//A
                                                             {4'b1000, 4'b1101}: keyboard_val <= 4'b1011;//B
                                                             {4'b1000, 4'b1011}: keyboard_val <= 4'b1100;//C
                                                             {4'b1000, 4'b0111}: keyboard_val <= 4'b1101;//D
                      default: keyboard_val <= 4'b1111;
                    endcase
                    press <= 1;
                    idle[col] <= 0;
                  end else begin
                    keyboard_val <= 4'b0000;
                    press <= 0;
                    idle[col] <= 1;
                  end
    end
  end
  always @(posedge key_clk) begin
    if (rst) begin
        state <= 0;
        start <= 0;
    end
    else begin
      if (idle[col] == 0) state <= state;
        else begin
            case (keyboard_val)
                4'b1111: begin 
                start <= 0; 
                state <= state; //end
                end
                4'b1110: 
                begin 
                start <= 1; 
                state <= 0; //start
                end
                4'b1010: 
                state = state / 10;//backspace
                4'b1011, 4'b1100, 4'b1101: state <= state;
                default: state <= state * 10 + keyboard_val;
            endcase
        end
    end
  end
  always @(posedge key_clk) begin
    if (start == 0)
        wdata <= 0;
    else wdata <= state;
  end
endmodule
