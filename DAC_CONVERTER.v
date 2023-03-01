INTERFACING OF ONBOARD DAC WITH SPARTAN3E
---------------------------------------------------
-----------------------------------------------------
module dac (clk, reset, data, dac_cs, spi_sck, spi_mosi, spi_miso, dac_clr,
SPI_SS_B, AMP_CS, AD_CONV, SF_CEO, FPGA_INIT_B, command, address, data, send);

input clk;// 50 MHZ FPGA CLOCK,
input reset;
input spi_miso; // MASTER IN, SLAVE OUT
input [11:0]data; // DIGITAL TO BE GIVEN TO DAC MODULE input [3:0]address; // DAC ADDRESS FOR A,B,C,D PIN

output reg send;
output reg dac_cs, spi_sck, spi_mosi, dac_clr; // SIGNAL ON DAC 
output SPI_SS_B, AMP_CS, AD_CONV, SF_CEO, FPGA_INIT_B; // PERIPHERAL SIGNAL TO BE DISABLED

output reg [3:0]command; // COMMAND =4'B0011

reg[2:0]dac_state; //DAC STATE
reg[31:0]dac_out; //DAC INPUT
data,4'b don't care} //usual command
reg [5:0]count=32; // 32 BIT COUNTER

assign SPI_SS_B=1; // SPI FLASH
assign AMP_CS=1; // AMPLIFIER SELECT
assign AD_CONV=0; // ADC CONVERSION
assign SF_CE0=1; // STRATA FLASH
assign FPGA_INIT_B=1; // PLATFORM FLASH

always@(posedge clk or posedge reset)
begin 
if(reset==1) // DISABLING OTHER PERIPHERALS CONNECTED TO SPI
begin
dac_cs<=1;
spi_sck<=0;
spi_mosi<=0;
dac_clr<=1;
send<=0;
dac_state<=0;
end
else begin

case(dac_state) // DAC STATES

0:begin // IDLE
dac_cs<=1;
spi_sck<=0;
spi_mosi<=0;
dac_clr<=1;
send<=0;
dac_state<=dac_state+1;
end

1:begin // 32 BIT ASSIGNING to DAC 
dac_out<={8'be0000000,4'b0011, 4'b0000, 12'b101100000000,4'b0000}; 
dac_state<=dac_state+1;
end

2:begin // BIT ASSIGNING ON SPI_MOSI LINE
dac_cs<=0; // FPGA TRANSMITS DATA ON MOSI Line when DAC_CS<=0;
spi_sck<=0; 
spi_mosi<=dac_out [count-1]; // ASSIGNING DIGITAL BIT TO MOSI LINE, STARTING 
FROM MSB 
count<=count-1; dac_state<=dac_state+1; end
3:begin // WAITING FOR COMPLETE 32 BIT INPUT TO MOSI
if(count>0) 
begin 
spi_sck<=1;
dac_state<=2;
end

else
begin
spi_sck<=1; I
dac_state<=dac_state+1;
end
end

4:begin
spi_sck<=0;
dac_state<=dac_state+1;
end

5:begin 
dac_cs<=1; // ANALOG CONVERSION STARTS, WHEN DAC_CS<=1;AFTER ASSIGNING 32 
BIT TO MOSI Line dac_state<=dac_state+1;
end

6:begin
send<=1;
dac_state<=dac_state+1;
end

7:begin
send<=0;
dac_state<=1;
end

default:begin
dac_cs<=1;
spi_mosi<=0;
spi_sck<=0;
dac_clr<=1;
send<=0;
dac_state<=0;
count<=32;
end

endcase
end
end
endmodule
