`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2023 10:27:59 AM
// Design Name: 
// Module Name: sort_fixed
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


module sort_fixed
    #(parameter M=8, N=32)
        (a_in, clock, rst, outP, outvalid);

    input [N-1:0] a_in;
    input clock, rst;
    output reg [N-1:0] outP;
    output reg outvalid;
    
    parameter S0 = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, 
    S4 = 4'd4, S5 = 4'd5, S6 = 4'd6, S7 = 4'd7, S8 = 4'd8,
    S9 = 4'd9;
    
    reg [3:0] next_state, curr_state;
    reg [5:0] i, j, i_srt, j_srt, i_stk;
    reg [N-1:0] arr [M-1:0];
    reg [5:0] stk1 [M-1:0];
    reg [5:0] stk2 [M-1:0];
    reg push, pop, done, start;
    reg empty;
    reg [5:0] indxp1, indxp2, ind1, ind2, pi;
    wire [N-1:0] pivot;
    wire comp_flt;
    
    always@(posedge clock) begin
        if(rst) curr_state <= S0;
        else curr_state <= next_state;
    end

    always@(curr_state, a_in) begin
        case(curr_state) 
        S0:   begin next_state <= S1;  
                    i <= 'b0;
                    j <= 'b0;
                    i_stk <= 'b0;
                    outP <= 'b0;
                    outvalid <= 'b0;
              end
        S1:   begin push <= 'b0;
                    arr[i] <= a_in;
                    i <= i + 'b1;
                    next_state <= (i==M-1) ? S2 : S1; 
                    outP <= 'b0;
                 end
        S2:  begin
                    indxp1 <= 'b0; //for starting sort
                    indxp2 <= M-1;
                    push <= 'b1;
                    next_state <= S3;
             end                      
        S3:  begin
                push <= 'b0;
                pop <= 'b1;
                start <= 'b0;
                next_state <= S4;
             end
        S4:  begin
                pop <= 'b0;
                if(empty=='b1)
                next_state <= S8;
                else if($signed(ind1) >= $signed(ind2))
                next_state <= S3;
                else begin
                //start <= 'b1;
                next_state <= (done=='b1) ? S6 : S5;
                end
             end
         S5 : begin 
                start <= 'b1;
                next_state <= (done=='b1) ? S6 : S4;
              end
         S6: begin 
                 indxp1 <= ind1;
                 indxp2 <= pi-1;
                 push <= 'b1;
                 next_state <= S7;
             end
         S7: begin 
                 indxp1 <= pi+1;
                 indxp2 <= ind2;
                 push <= 'b1;
                 next_state <= S3;
             end
         S8: begin
                outP <= arr[j];
                j <= j + 1;
                outvalid <= 'b1;
                next_state <= (j==M-1) ? S0 : S9; 
             end
         S9: begin 
                outP <= arr[j];
                j <= j + 1;
                outvalid <= 'b1;
                next_state <= (j==M-1) ? S0 : S8; 
             end
        default: begin next_state <= S0;  
                    i <= 'b0;
                    outP <= 'b0; 
                 end
        endcase
    end
    
    //SORTER
    assign pivot = arr[ind2];
    always@(posedge clock) begin
    if(start == 'b0) begin
    j_srt <= ind1;
    i_srt <= ind1;
    done <= 'b0; end
    else if((start == 'b1) && (done == 'b0))  begin
    if((comp_flt)&(j_srt<ind2)/*$signed(arr[j_srt]) < $signed(pivot)*/) begin	//just change logic here for fixed and flt
    arr[i_srt] <= arr[j_srt];
    arr[j_srt] <= arr[i_srt];
    i_srt <= i_srt + 'b1; end
    else if(j_srt == ind2) begin
    arr[i_srt] <= pivot;
    arr[ind2] <= arr[i_srt];
    pi <= i_srt;
    done <= 'b1; end
    j_srt <= j_srt + 'b1;
    end
    else begin
    j_srt <= 'b0;
    i_srt <= 'b0;
    done <= 'b0; end 
    end
    
    //floating number compare
    assign comp_flt = (pivot[N-1]>arr[j_srt%M][N-1]) ? 'b0 :
                        (pivot[N-1]<arr[j_srt%M][N-1]) ? 'b1 :
                          (pivot[N-2:0]<arr[j_srt%M][N-2:0]) ? arr[j_srt%M][N-1] : ~arr[j_srt%M][N-1];
    
    //STACK
    always@(posedge clock) begin
    if(push == 'b1) begin
    stk1[i_stk] <= indxp1;
    stk2[i_stk] <= indxp2;
    i_stk <= i_stk + 'b1; end
    else if((pop == 'b1) & (i_stk != 'b0)) begin
    ind1 <= stk1[i_stk-1];
    ind2 <= stk2[i_stk-1];
    i_stk <= i_stk - 'b1; end
    else empty = (pop == 'b1) & (i_stk == 'b0);
    end
        
endmodule
