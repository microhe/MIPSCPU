`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2017 11:58:29 PM
// Design Name: 
// Module Name: key16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module key16(
    input wire reset,       //复位信号
    input wire cs,          //片选信号，接keyctrl
    input wire clk,         //系统时钟
    input wire ior,         //读信号
    input wire[1:0] address,//端口号
    input wire[3:0] col,    //列线
    output reg[3:0] line,   //行线
    output reg[15:0] ioread_data//输出数据
    );

    reg[15:0] keyvalue;
    reg[15:0] keystat;

    always @(negedge clk) begin
        if (reset == 1) begin
            // reset
            ioread_data = 16'h0000;
            keyvalue = 16'h0000;
            keystat = 16'h0000;
            line = 4'h0;
        end
        else begin
            case(line)
                4'b0000: if(col != 4'b1111) line <= 4'b1110;
                4'b1110: //0行
                    if(col != 4'b1111) begin
                        keyvalue[3:0] = col;
                        keyvalue[7:4] = line;
                        keystat = keystat | 16'h0001;
                        line <= 4'b0000;
                    end 
                    else begin
                        line <= 4'b1101;
                    end
                4'b1101: //1行
                    if(col != 4'b1111) begin
                        keyvalue[3:0] = col;
                        keyvalue[7:4] = line;
                        keystat = keystat | 16'h0001;
                        line <= 4'b0000;
                    end 
                    else begin
                        line <= 4'b1011;
                    end
                4'b1011: //2行
                    if(col != 4'b1111) begin
                        keyvalue[3:0] = col;
                        keyvalue[7:4] = line;
                        keystat = keystat | 16'h0001;
                        line <= 4'b0000;
                    end 
                    else begin
                        line <= 4'b0111;
                    end
                4'b0111: //3行
                    if(col != 4'b1111) begin
                        keyvalue[3:0] = col;
                        keyvalue[7:4] = line;
                        keystat = keystat | 16'h0001;
                        line <= 4'b0000;
                    end 
                    else begin
                        line <= 4'b0000;
                        keystat = keystat & 16'hfffe;
                    end
            endcase

            if ((cs == 1) && (ior == 1)) begin // 读信号
                if (address == 2'b00) begin    //读键值
                    ioread_data = keyvalue;
                end
                else if(address == 2'b10) begin //读状态同时清状态
                    ioread_data = keystat;
                    keystat = keystat & 16'hfffe;
                end
            end
        end
    end
endmodule