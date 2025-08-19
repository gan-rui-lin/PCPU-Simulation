// testbench for simulation
module sccomp_tb ();

  reg clk, rstn;
  reg  [ 4:0] reg_sel;
  wire [31:0] reg_data;

  // instantiation of sccomp    
  sccomp U_SCCOMP (
      .clk(clk),
      .rstn(rstn),
      .reg_sel(reg_sel),
      .reg_data(reg_data)
  );

  integer foutput;
  integer debug_output;
  integer pc_output;
  integer reg_output;
  integer counter = 0;

  initial begin
    // $readmemh("Test_8_Instr.dat", U_SCCOMP.U_IM.ROM, 0,
    // $readmemh("sim5.dat", U_SCCOMP.U_IM.ROM, 0, 26);  // load instructions into instruction memory
    // $readmemh("sim6.dat", U_SCCOMP.U_IM.ROM, 0, 
    // 192);
      // $readmemh("sim1.dat", U_SCCOMP.U_IM.ROM, 0, 30);
      // $readmemh("sim1_f.dat", U_SCCOMP.U_IM.ROM, 0, 30);
      // $readmemh("sim2_f.dat", U_SCCOMP.U_IM.ROM, 0, 26);
      $readmemh("sim3_f.dat", U_SCCOMP.U_IM.ROM, 0, 30);
      // $readmemh("sim4_f.dat", U_SCCOMP.U_IM.ROM, 0, 30);
      // $readmemh("riscv32_sort_sim.dat", U_SCCOMP.U_IM.ROM, 0, 80);
      // $readmemh("self_abab.dat", U_SCCOMP.U_IM.ROM, 0, 80);
      

      // $readmemh("hhh.dat", U_SCCOMP.U_IM.ROM, 0, 30);
    // $monitor("PC = 0x%8X, instr = 0x%8X", U_SCCOMP.PC, U_SCCOMP.instr); // used for debug
    foutput = $fopen("results.txt");
    debug_output = $fopen("debug.txt");
    pc_output = $fopen("pc.txt");
    // 打开 VCD 波形记录
    $dumpfile("a.vcd");
    $dumpvars(0, sccomp_tb);
    clk  = 1;
    rstn = 1;
    #5;
    rstn = 0;
    #20;
    rstn = 1;
    #1000;
    reg_sel = 7;
  end

  always begin
    #(50) clk = ~clk;

    if (clk == 1'b1) begin
      if ((counter == 1000) || (U_SCCOMP.U_SCPU.PC_out === 32'hxxxxxxxx)) begin
        $fclose(foutput);
        $stop;
      end else begin
        if (U_SCCOMP.PC == 32'h100) begin
        // if (U_SCCOMP.PC == 32'hA8) begin
          counter = counter + 1;
          $fdisplay(foutput, "pc:\t %h", U_SCCOMP.PC);
          $fdisplay(foutput, "instr:\t\t %h", U_SCCOMP.instr);
          $fdisplay(foutput, "rf00-03:\t %h %h %h %h", 0, U_SCCOMP.U_SCPU.U_RF.rf[1],
                    U_SCCOMP.U_SCPU.U_RF.rf[2], U_SCCOMP.U_SCPU.U_RF.rf[3]);
          $fdisplay(foutput, "rf04-07:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[4],
                    U_SCCOMP.U_SCPU.U_RF.rf[5], U_SCCOMP.U_SCPU.U_RF.rf[6],
                    U_SCCOMP.U_SCPU.U_RF.rf[7]);
          $fdisplay(foutput, "rf08-11:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[8],
                    U_SCCOMP.U_SCPU.U_RF.rf[9], U_SCCOMP.U_SCPU.U_RF.rf[10],
                    U_SCCOMP.U_SCPU.U_RF.rf[11]);
          $fdisplay(foutput, "rf12-15:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[12],
                    U_SCCOMP.U_SCPU.U_RF.rf[13], U_SCCOMP.U_SCPU.U_RF.rf[14],
                    U_SCCOMP.U_SCPU.U_RF.rf[15]);
          $fdisplay(foutput, "rf16-19:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[16],
                    U_SCCOMP.U_SCPU.U_RF.rf[17], U_SCCOMP.U_SCPU.U_RF.rf[18],
                    U_SCCOMP.U_SCPU.U_RF.rf[19]);
          $fdisplay(foutput, "rf20-23:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[20],
                    U_SCCOMP.U_SCPU.U_RF.rf[21], U_SCCOMP.U_SCPU.U_RF.rf[22],
                    U_SCCOMP.U_SCPU.U_RF.rf[23]);
          $fdisplay(foutput, "rf24-27:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[24],
                    U_SCCOMP.U_SCPU.U_RF.rf[25], U_SCCOMP.U_SCPU.U_RF.rf[26],
                    U_SCCOMP.U_SCPU.U_RF.rf[27]);
          $fdisplay(foutput, "rf28-31:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[28],
                    U_SCCOMP.U_SCPU.U_RF.rf[29], U_SCCOMP.U_SCPU.U_RF.rf[30],
                    U_SCCOMP.U_SCPU.U_RF.rf[31]);
          //$fdisplay(foutput, "hi lo:\t %h %h", U_SCCOMP.U_SCPU.U_RF.rf.hi, U_SCCOMP.U_SCPU.U_RF.rf.lo);
          $fclose(foutput);
          $stop;
        end else begin
          counter = counter + 1;
          // $display("pc: %h", U_SCCOMP.PC);
                  //  $display("instr: %h", U_SCCOMP.U_SCPU.instr);
        end

        $fdisplay(pc_output, "PC = %h", U_SCCOMP.U_SCPU.PC_out);
        // 无论如何, 写入调试日志
        if (counter < 32) begin
          $fdisplay(debug_output, "Cycle %0d", counter);

          // ----- Actual In and Out -----
          $fdisplay(debug_output, "----- Actual In and Out -----");
          $fdisplay(debug_output, "PC_out = %h, inst_in = %h", U_SCCOMP.U_SCPU.PC_out,
                    U_SCCOMP.U_SCPU.inst_in);
          $fdisplay(debug_output, "Data_in = %h, mem_w = %b", U_SCCOMP.U_SCPU.Data_in,
                    U_SCCOMP.U_SCPU.mem_w);
          $fdisplay(debug_output, "Addr_out = %h, Data_out = %h", U_SCCOMP.U_SCPU.Addr_out,
                    U_SCCOMP.U_SCPU.Data_out);
          $fdisplay(debug_output, "reg_sel = %d, reg_data = %h", U_SCCOMP.U_SCPU.reg_sel,
                    U_SCCOMP.U_SCPU.reg_data);
          $fdisplay(debug_output, "DMType_out = %h", U_SCCOMP.U_SCPU.DMType_out);
          $fdisplay(debug_output, "MemRead_out = %h", U_SCCOMP.U_SCPU.MemRead_out);


          // ----- IF/ID -----
          $fdisplay(debug_output, "----- IF/ID -----");
          $fdisplay(debug_output, "valid = %b, PC = %h, Inst = %h", U_SCCOMP.U_SCPU.IF_ID_valid,
                    U_SCCOMP.U_SCPU.IF_ID_PC, U_SCCOMP.U_SCPU.IF_ID_Inst);

          // ----- ID/EX -----
          $fdisplay(debug_output, "----- ID/EX -----");
          $fdisplay(debug_output, "valid = %b, PC = %h, RD1 = %h, RD2 = %h, Imm = %h",
                    U_SCCOMP.U_SCPU.ID_EX_valid, U_SCCOMP.U_SCPU.ID_EX_PC,
                    U_SCCOMP.U_SCPU.ID_EX_RD1, U_SCCOMP.U_SCPU.ID_EX_RD2,
                    U_SCCOMP.U_SCPU.ID_EX_Imm);
          $fdisplay(
              debug_output,
              "rs1 = %d, rs2 = %d, rd = %d, ALUOp = %h, ALUSrc = %b, RegWrite = %b, WDSel = %b, DMType = %h, MemWrite = %h",
              U_SCCOMP.U_SCPU.ID_EX_rs1, U_SCCOMP.U_SCPU.ID_EX_rs2, U_SCCOMP.U_SCPU.ID_EX_rd,
              U_SCCOMP.U_SCPU.ID_EX_ALUOp, U_SCCOMP.U_SCPU.ID_EX_ALUSrc,
              U_SCCOMP.U_SCPU.ID_EX_RegWrite, U_SCCOMP.U_SCPU.ID_EX_WDSel,
              U_SCCOMP.U_SCPU.ID_EX_DMType, U_SCCOMP.U_SCPU.ID_EX_MemWrite);

          // ----- EX/MEM -----
          $fdisplay(debug_output, "----- EX/MEM -----");
          $fdisplay(debug_output, "valid = %b, PC = %h, ALUResult = %h, RD2 = %h, rd = %d",
                    U_SCCOMP.U_SCPU.EX_MEM_valid, U_SCCOMP.U_SCPU.EX_MEM_PC,
                    U_SCCOMP.U_SCPU.EX_MEM_ALUResult, U_SCCOMP.U_SCPU.EX_MEM_RD2,
                    U_SCCOMP.U_SCPU.EX_MEM_rd);
          $fdisplay(debug_output, "RegWrite = %b, MemWrite = %b, WDSel = %b, DMType = %h, MemRead = %h",
                    U_SCCOMP.U_SCPU.EX_MEM_RegWrite, U_SCCOMP.U_SCPU.EX_MEM_MemWrite,
                    U_SCCOMP.U_SCPU.EX_MEM_WDSel, U_SCCOMP.U_SCPU.EX_MEM_DMType, 
                    U_SCCOMP.U_SCPU.EX_MEM_MemRead);

          // ----- MEM/WB -----
          $fdisplay(debug_output, "----- MEM/WB -----");
          $fdisplay(debug_output, "valid = %b, PC = %h, MemData = %h, ALUResult = %h, rd = %d",
                    U_SCCOMP.U_SCPU.MEM_WB_valid, U_SCCOMP.U_SCPU.MEM_WB_PC,
                    U_SCCOMP.U_SCPU.MEM_WB_MemData, U_SCCOMP.U_SCPU.MEM_WB_ALUResult,
                    U_SCCOMP.U_SCPU.MEM_WB_rd);
          $fdisplay(debug_output, "RegWrite = %b, WDSel = %b\n", U_SCCOMP.U_SCPU.MEM_WB_RegWrite,
                    U_SCCOMP.U_SCPU.MEM_WB_WDSel);
        end

      end
    end
  end  //end always

endmodule
