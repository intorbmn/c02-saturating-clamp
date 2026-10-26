// C02 - Bo kep gia tri bao hoa 8-bit (mach to hop)
//
// Giao dien (kieu Tiny Tapeout):
//   ui_in[7:0]   = mau vao
//   uio_in[7:4]  = nguong duoi  -> lo = {uio_in[7:4], 4'h0}
//   uio_in[3:1]  = nguong tren  -> hi = {uio_in[3:1], 5'h1F}
//   uio_in[0]    = KHONG DUNG (chan nay la dau ra co kep)
//   uo_out[7:0]  = mau da kep
//   uio_out[0]   = co kep (1 khi mau bi kep)
//
// !! Cach ma hoa nguong o tren la GIA DINH cua huong dan nay.
//    Neu de bai cua ban quy dinh khac, chi sua 2 dong "lo" va "hi" o module top.
//
// Tach 3 module de bao cao tong hop cho thay RIENG phan so sanh va phan ghep kenh.

// ---- Phan 1: SO SANH ------------------------------------------------
module clamp_cmp (
    input  [7:0] s,
    input  [7:0] lo,
    input  [7:0] hi,
    output       below,   // s < lo
    output       above    // s > hi
);
    assign below = (s < lo);
    assign above = (s > hi);
endmodule

// ---- Phan 2: GHEP KENH CHON GIA TRI RA -------------------------------
module clamp_mux (
    input  [7:0] s,
    input  [7:0] lo,
    input  [7:0] hi,
    input        below,
    input        above,
    output [7:0] y
);
    // uu tien: duoi nguong duoi -> lo ; tren nguong tren -> hi ; con lai giu nguyen
    assign y = below ? lo : (above ? hi : s);
endmodule

// ---- Top -------------------------------------------------------------
module sat_clamp (
    input  [7:0] ui_in,
    input  [7:0] uio_in,
    output [7:0] uo_out,
    output [7:0] uio_out,
    output [7:0] uio_oe
);
    wire [7:0] lo = {uio_in[7:4], 4'h0};
    wire [7:0] hi = {uio_in[3:1], 5'h1F};
    wire below, above;

    clamp_cmp u_cmp (.s(ui_in), .lo(lo), .hi(hi), .below(below), .above(above));
    clamp_mux u_mux (.s(ui_in), .lo(lo), .hi(hi), .below(below), .above(above), .y(uo_out));

    assign uio_out = {7'b0, below | above};   // co kep
    assign uio_oe  = 8'h01;                   // chi bit 0 la dau ra
endmodule
