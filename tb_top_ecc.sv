`timescale 1ns / 1ps

module tb_top_ecc(    );

logic T_CLK = 0;
logic T_RESET;
logic [79:0] T_PX, T_PY, T_QX, T_QY, T_RX, T_RY;

logic T_START, T_DONE;

top_ecc dut (.px(T_PX), .py(T_PY), .qx(T_QX), .qy(T_QY), .clk(T_CLK), .reset(T_RESET), .start(T_START), .done(T_DONE), .rx(T_RX), .ry(T_RY)); 


always
#5 T_CLK = ~T_CLK;

task add (input logic [79:0] px, py, qx, qy);
T_PX = px;
T_PY = py;
T_QX = qx;
T_QY = qy;

T_START = 1'b1;
#15; 
T_START = 1'b0;

@(negedge T_DONE);
#10;
$display("Adding P=(%0x, %0x) and Q=(%0x, %0x)\nRX=%0x RY=%0x", T_PX, T_PY, T_QX, T_QY, T_RX, T_RY);
endtask

task double (input logic [79:0] px, py);
T_PX = px;
T_PY = py;

T_PX[79] = 1'b1;

T_START = 1'b1;
#15; 
T_START = 1'b0;

@(negedge T_DONE);
#10;
T_PX[79] = 1'b0;
$display("Doubling P=(%0x, %0x)\nRX=%0x RY=%0x", T_PX, T_PY, T_RX, T_RY);
endtask

task addZeroP (input logic [79:0] px, py);
T_PX = px;
T_PY = py;
T_QX = 79'h0;
T_QY = 79'h0;

T_START = 1'b1;
#15; 
T_START = 1'b0;

@(negedge T_DONE);
#10;
$display("Adding 0 to P=(%0x, %0x)\nRX=%0x RY=%0x", T_PX, T_PY, T_RX, T_RY);
endtask

task addZeroQ (input logic [79:0] qx, qy);
T_QX = qx;
T_QY = qy;
T_PX = 79'h0;
T_PY = 79'h0;

T_START = 1'b1;
#15; 
T_START = 1'b0;

@(negedge T_DONE);
#10;
$display("Adding 0 to Q=(%0x, %0x)\nRX=%0x RY=%0x", T_QX, T_QY, T_RX, T_RY);
endtask

task substract (input logic [79:0] px, py,  qx, qy);
T_PX = px;
T_PY = py;
T_QX = qx;
T_QY = qy;

T_QY[79] = 1'b1;

T_START = 1'b1;
#15; 
T_START = 1'b0;

@(negedge T_DONE);
#10;
T_QY[79] = 1'b0;
$display("Substracting Q=(%0x, %0x) from P=(%0x, %0x)\nRX=%0x RY=%0x", T_QX, T_QY, T_PX, T_PY, T_RX, T_RY);
endtask

initial
begin


T_RESET = 1;
#15;
T_RESET = 0;

add(79'h30CB127B63E42792F10F, 79'h547B2C88266BB04F713B, 79'h00202A9F035014497325, 79'h5175A64859552F97C129);
double(79'h30CB127B63E42792F10F, 79'h547B2C88266BB04F713B);
addZeroP(79'h30CB127B63E42792F10F, 79'h547B2C88266BB04F713B);
addZeroQ(79'h00202A9F035014497325, 79'h5175A64859552F97C129);
substract(79'h30CB127B63E42792F10F, 79'h547B2C88266BB04F713B, 79'h00202A9F035014497325, 79'h5175A64859552F97C129);

$display("END");

end

endmodule

/*
entity top_ecc is
    Port (  px : in STD_LOGIC_VECTOR (79 downto 0);
            py : in STD_LOGIC_VECTOR (79 downto 0);
            qx : in STD_LOGIC_VECTOR (79 downto 0);
            qy : in STD_LOGIC_VECTOR (79 downto 0);
            clk, reset : in std_logic;
            start : in std_logic;
            
            done : out std_logic;
            rx : out STD_LOGIC_VECTOR (79 downto 0);
            ry : out STD_LOGIC_VECTOR (79 downto 0)                        
    );
end top_ecc;
*/