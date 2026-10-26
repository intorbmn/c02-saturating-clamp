`timescale 1ns/1ps
// Testbench thuong: 5 ca theo de bai, in tung dong de doc bang mat.
module tb_sat_clamp;
    reg  [7:0] ui_in, uio_in;
    wire [7:0] uo_out, uio_out, uio_oe;

    sat_clamp dut (.ui_in(ui_in), .uio_in(uio_in),
                   .uo_out(uo_out), .uio_out(uio_out), .uio_oe(uio_oe));

    // lo = 0x40 (uio_in[7:4]=4), hi = 0xBF (uio_in[3:1]=5)
    localparam [7:0] CFG = {4'h4, 3'd5, 1'b0};

    task ca(input [127:0] ten, input [7:0] s);
        begin
            ui_in = s; uio_in = CFG; #10;
            $display("%-18s s=0x%02h  lo=0x40 hi=0xBF  ->  out=0x%02h  clamp=%b",
                     ten, s, uo_out, uio_out[0]);
        end
    endtask

    initial begin
        $dumpfile("waveforms/sat_clamp.vcd");
        $dumpvars(0, tb_sat_clamp);
        ca("duoi nguong duoi", 8'h30);
        ca("dung bien duoi",   8'h40);
        ca("trong khoang",     8'h80);
        ca("dung bien tren",   8'hBF);
        ca("tren nguong tren", 8'hF0);
        $finish;
    end
endmodule
