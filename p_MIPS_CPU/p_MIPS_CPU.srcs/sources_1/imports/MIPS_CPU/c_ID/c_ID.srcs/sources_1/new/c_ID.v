`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/24 16:17:42
// Design Name: 
// Module Name: c_ID
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


module c_ID(
    input clk,                          //����ʱ��
    input[31:0] Instruction_id,         //��ִ��ָ��
    input[31:0] NextPC_id,              //PC+4��ַ
    input RegWr_wb,                     //Regs��дʹ���ź�
    input[4:0] RegWrAddr_wb,            //Regs��д�Ĵ�����ַ
    input[31:0] RegWrData_wb,           //Regs��д������
    input MemRead_ex,                   //��һ��ָ���Ƕ�MEMָ����źţ������ж�ð�շ���������
    input[4:0] RegWrAddr_ex,            //��һ��ָ��д��Regs�ĵ�ַ�������ж�ð�շ���������
    output MemToReg_id,                 //�������ɵ�ѡ���дRegs����Դ�Ŀ����ź�
    output RegWr_id,                    //�������ɵ����ڻ�дRegs��ʹ���ź�
    output MemWr_id,                    //�������ɵ�����дMEM��ʹ���ź�
    output MemRead_id,                  //�������ɵ�ָʾ��ǰָ���Ƕ�MEM���ź�
    output[1:0] MemReadSize_id,         //�������ɵ������ж϶�MEMָ���ȡλ���Ŀ����ź�
    output MemExtType_id,               //�������ɵ����ڿ��ƶ�MEMָ����������չ��ʽ�Ŀ����ź�
    output[4:0] ALUCode_id,             //�������ɵ�����ѡ��ALU���㹦�ܵ��ź�
    output ALUsrcA_id,                  //�������ɵ�����ѡ��ALU������A������Դ�Ŀ����ź�
    output ALUsrcB_id,                  //�������ɵ�����ѡ��ALU������A������Դ�Ŀ����ź�
    output RegDst_id,                   //�������ɵ�����ѡ���дRegs��ַ�Ŀ����ź�
    output Stall,                       //����ð��ʱ�������ID/EX��Reg�Ŀ����ź�
    output PC_IFWrite,                  //����ð��ʱ������ͣIF/ID��Reg�Ŀ����ź�
    output IF_flush,                    //������ת��֧��ͻ�Ŀ����ź�
    output Z,                        //��ָ֧�������������ź�
    output J,                           //��תָ��
    output JR,                          //�Ĵ�����תָ��
    output JAL,                      //�豣��PC��ַ��ָ��
    output BAL,                      //��֧��ת���豣��PC��ַ��ָ��
    output[31:0] BranchAddr,            //��֧��תĿ���ַ
    output[31:0] JmpAddr,               //��������תĿ���ַ
    output[31:0] JrAddr,                //�Ĵ�����תĿ���ַ
    output[31:0] RsData_id,             
    output[31:0] RtData_id,             
    output[4:0] RsAddr_id,             
    output[4:0] RtAddr_id,             
    output[4:0] RdAddr_id,             
    output[31:0] Sa_id,                 //����չ��32bit����λ������
    output[31:0] Imme_id                //������չ��32bit��������
    );
    assign RsAddr_id = Instruction_id[25:21];
    assign RtAddr_id = Instruction_id[20:16];
    assign RdAddr_id = Instruction_id[15:11];
    assign Sa_id = {27'b0,Instruction_id[10:6]};
    assign Imme_id = {{16{Instruction_id[15]}},Instruction_id[15:0]};
    assign JmpAddr = {NextPC_id[31:28],Instruction_id[25:0],2'b00};
    assign JrAddr = RsData_id;
    assign IF_flush = Z || J || JR;
    wire[31:0] Imme_shift;
    assign Imme_shift = Imme_id << 2;
    //�˴�δ���߽��⣬��NextPC+offset < 0 ʱ���൱����ת��β����Ӧλ��
    Branch_adder branchAdder (
      .A(NextPC_id),  // input wire [31 : 0] A
      .B(Imme_shift),  // input wire [31 : 0] B
      .S(BranchAddr)  // output wire [31 : 0] S
    );
    //������
    m_Decoder Decoder(
    .op(Instruction_id[31:26]),
    .func(Instruction_id[5:0]),
    .MemToReg(MemToReg_id),
    .MemWr(MemWr_id),
    .MemRead(MemRead_id),
    .MemReadSize(MemReadSize_id),
    .MemExtType(MemExtType_id),
    .RegWr(RegWr_id),
    .RegDst(RegDst_id),
    .ALUsrcA(ALUsrcA_id),
    .ALUsrcB(ALUsrcB_id),
    .ALUCode(ALUCode_id),
    .Jmp(J),
    .Jr(JR),
    .Jal(JAL),
    .Bal(BAL)
    );
    //Regs
    m_Regs Regs(
    .clk(clk),
    .RegWr(RegWr_wb),
    .RsAddr(RsAddr_id),
    .RtAddr(RtAddr_id),
    .RegWrAddr(RegWrAddr_wb),
    .RegWrData(RegWrData_wb),
    .RsData(RsData_id),
    .RtData(RtData_id)
    );
    //ZeroTest
    m_ZeroTest ZeroTest(
    .ALUCode_id(ALUCode_id),
    .RsData_id(RsData_id),
    .RtData_id(RtData_id),
    .Z(Z)
    );
    //HazardDectector
    m_HazardDetector HazardDetector(
    .MemRead_ex(MemRead_ex),
    .RegWrAddr_ex(RegWrAddr_ex),
    .RsAddr_id(RsAddr_id),
    .RtAddr_id(RtAddr_id),
    .PC_IFWrite(PC_IFWrite),
    .Stall(Stall)
    );
    
    
endmodule