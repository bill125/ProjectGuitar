library verilog;
use verilog.vl_types.all;
entity test_vlg_check_tst is
    port(
        clk             : in     vl_logic;
        start_out       : in     vl_logic;
        test            : in     vl_logic_vector(5 downto 0);
        sampler_rx      : in     vl_logic
    );
end test_vlg_check_tst;
