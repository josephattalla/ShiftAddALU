module fullAdder (
    a,
    b,
    cin,
    s,
    cout
);
  input a, b, cin;
  output s, cout;

  assign s = a ^ b ^ cin;  // sum
  assign cout = (a & b) | ((a ^ b) & cin);  // carryout

endmodule

module adder4 (
    a,
    b,
    s,
    cin,
    cout,
    z
);
  input [3:0] a, b;  // 4 bit inputs
  input s;  // add/subtract bit
  input cin;  // carry in
  output [3:0] z;  // 4 bit result
  output cout;  // final carry out
  wire [3:1] carryout;  // internal carry wires

  // 4 full adders
  fullAdder stage0 (
      a[0],
      b[0] ^ s,
      cin,
      z[0],
      carryout[1]
  );
  fullAdder stage1 (
      a[1],
      b[1] ^ s,
      carryout[1],
      z[1],
      carryout[2]
  );
  fullAdder stage2 (
      a[2],
      b[2] ^ s,
      carryout[2],
      z[2],
      carryout[3]
  );
  fullAdder stage3 (
      a[3],
      b[3] ^ s,
      carryout[3],
      z[3],
      cout
  );

endmodule

module mux2to1 (
    input [1:0] in,  // 2 bit input signals
    input sel,  // 1 bit selector signal
    output out  // output signal
);
  assign out = (in[1] & sel) | (in[0] & ~sel);
endmodule

module mux4to1 (
    input [3:0] in,  // 4 input signals
    input [1:0] sel,  // 2 selector signals
    output out  // 1 bit output
);
  assign out = in[sel];
endmodule

module mux16to1 (
    input [15:0] in,   // 16 input signals
    input [3:0] sel,   // 4-bit selection line
    output reg out     // Output signal
);

  always @(*) begin
    case (sel)
      4'b0000: out = in[0];
      4'b0001: out = in[1];
      4'b0010: out = in[2];
      4'b0011: out = in[3];
      4'b0100: out = in[4];
      4'b0101: out = in[5];
      4'b0110: out = in[6];
      4'b0111: out = in[7];
      4'b1000: out = in[8];
      4'b1001: out = in[9];
      4'b1010: out = in[10];
      4'b1011: out = in[11];
      4'b1100: out = in[12];
      4'b1101: out = in[13];
      4'b1110: out = in[14];
      4'b1111: out = in[15];
      default: out = 1'b0;  // Default output for undefined cases
    endcase
  end
endmodule


module arithmeticAlu (
    input [3:0] A,
    input [3:0] B,
    input [2:0] S,
    input Cin,
    output [3:0] result,
    output Cout
);

  // selector lines
  wire [3:0] selectors = {S[2:0], Cin};

  // operation results
  wire [3:0] add;
  wire [3:0] negA;
  wire [3:0] incrementA;
  wire [3:0] decrementB;
  wire [3:0] AandB;
  wire [3:0] AorB;
  wire [3:0] notA;
  wire [3:0] AxorB;
  wire [2:0] carry;

  // operations
  adder4 op0 (
      A,
      B,
      S[0],
      Cin,
      carry[0],
      add
  );
  adder4 op1 (
      A,
      4'b0001,
      0,
      0,
      carry[1],
      incrementA
  );
  adder4 op2 (
      B,
      4'b0001,
      1,
      1,
      carry[2],
      decrementB
  );
  assign negA  = (A ^ 4'b1111) + 4'b0001;
  assign AandB = A & B;
  assign AorB  = A | B;
  assign notA  = ~A;
  assign AxorB = A ^ B;

  // first bit mux
  wire [15:0] bit0;
  assign bit0 = {
    AxorB[0],
    AxorB[0],
    notA[0],
    notA[0],
    AorB[0],
    AorB[0],
    AandB[0],
    AandB[0],
    A[0],
    decrementB[0],
    incrementA[0],
    negA[0],
    add[0],
    add[0],
    add[0],
    add[0]
  };
  mux16to1 stage0 (
      bit0,
      selectors,
      result[0]
  );

  // second bit mux
  wire [15:0] bit1;
  assign bit1 = {
    AxorB[1],
    AxorB[1],
    notA[1],
    notA[1],
    AorB[1],
    AorB[1],
    AandB[1],
    AandB[1],
    A[1],
    decrementB[1],
    incrementA[1],
    negA[1],
    add[1],
    add[1],
    add[1],
    add[1]
  };
  mux16to1 stage1 (
      bit1,
      selectors,
      result[1]
  );

  // third bit mux
  wire [15:0] bit2;
  assign bit2 = {
    AxorB[2],
    AxorB[2],
    notA[2],
    notA[2],
    AorB[2],
    AorB[2],
    AandB[2],
    AandB[2],
    A[2],
    decrementB[2],
    incrementA[2],
    negA[2],
    add[2],
    add[2],
    add[2],
    add[2]
  };
  mux16to1 stage2 (
      bit2,
      selectors,
      result[2]
  );

  // fourth bit mux
  wire [15:0] bit3;
  assign bit3 = {
    AxorB[3],
    AxorB[3],
    notA[3],
    notA[3],
    AorB[3],
    AorB[3],
    AandB[3],
    AandB[3],
    A[3],
    decrementB[3],
    incrementA[3],
    negA[3],
    add[3],
    add[3],
    add[3],
    add[3]
  };
  mux16to1 stage3 (
      bit3,
      selectors,
      result[3]
  );

  // set carry out
  wire [15:0] carryOutBit;
  assign carryOutBit = {
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    carry[2],
    carry[1],
    1'b0,
    carry[0],
    carry[0],
    carry[0],
    carry[0]
  };
  mux16to1 carryStage (
      carryOutBit,
      selectors,
      Cout
  );

endmodule

module shiftAluUnit (
    input [1:0] S,
    input [3:0] A,
    output [3:0] result,
    output Cout
);
  // operation result wires
  wire [3:0] shrA;
  wire [3:0] shlA;
  wire [3:0] rLeftA;
  wire [3:0] rRightA;
  wire [3:0] carry;

  // assign results
  assign shrA = A >> 1;
  assign shlA = A << 1;
  assign rLeftA = {A[2:0], A[3]};
  assign rRightA = {A[0], A[3:1]};
  assign carry = {A[0], A[3], 1'b0, 1'b0};

  // first bit mux
  wire [3:0] bit0;
  assign bit0 = {rRightA[0], rLeftA[0], shlA[0], shrA[0]};
  mux4to1 stage0 (
      bit0,
      S,
      result[0]
  );

  // second bit mux
  wire [3:0] bit1;
  assign bit1 = {rRightA[1], rLeftA[1], shlA[1], shrA[1]};
  mux4to1 stage1 (
      bit1,
      S,
      result[1]
  );

  // third bit mux
  wire [3:0] bit2;
  assign bit2 = {rRightA[2], rLeftA[2], shlA[2], shrA[2]};
  mux4to1 stage2 (
      bit2,
      S,
      result[2]
  );

  // fourth bit mux
  wire [3:0] bit3;
  assign bit3 = {rRightA[3], rLeftA[3], shlA[3], shrA[3]};
  mux4to1 stage3 (
      bit3,
      S,
      result[3]
  );

  // carry mux
  mux4to1 stage4 (
      carry,
      S,
      Cout
  );


endmodule

module shiftALU (
    input [3:0] A,
    input [3:0] B,
    input [3:0] S,
    input Cin,
    output [3:0] result,
    output Cout
);
  // ALU result wires
  wire [3:0] arithmeticAluResult;
  wire [3:0] shiftAluResult;
  wire [1:0] carry;

  // perform operations
  arithmeticAlu alu0 (
      A,
      B,
      S[2:0],
      Cin,
      arithmeticAluResult,
      carry[0]
  );
  shiftAluUnit alu1 (
      S[1:0],
      A,
      shiftAluResult,
      carry[1]
  );

  // first bit mux
  wire [1:0] bit0;
  assign bit0 = {shiftAluResult[0], arithmeticAluResult[0]};
  mux2to1 stage0 (
      bit0,
      S[3],
      result[0]
  );

  // second bit mux
  wire [1:0] bit1;
  assign bit1 = {shiftAluResult[1], arithmeticAluResult[1]};
  mux2to1 stage1 (
      bit1,
      S[3],
      result[1]
  );

  // third bit mux
  wire [1:0] bit2;
  assign bit2 = {shiftAluResult[2], arithmeticAluResult[2]};
  mux2to1 stage2 (
      bit2,
      S[3],
      result[2]
  );

  // fourth bit mux
  wire [1:0] bit3;
  assign bit3 = {shiftAluResult[3], arithmeticAluResult[3]};
  mux2to1 stage3 (
      bit3,
      S[3],
      result[3]
  );

  // carry bit mux
  mux2to1 stage4 (
      carry,
      S[3],
      Cout
  );

endmodule
