library verilog;
use verilog.vl_types.all;
entity test_vlg_sample_tst is
    port(
        clk_in          : in     vl_logic;
        impulse_in      : in     vl_logic;
        start           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end test_vlg_sample_tst;
