library verilog;
use verilog.vl_types.all;
entity test is
    port(
        impulse_in      : in     vl_logic;
        start           : in     vl_logic;
        start_out       : out    vl_logic;
        clk_in          : in     vl_logic;
        test            : out    vl_logic_vector(5 downto 0);
        clk             : out    vl_logic
    );
end test;
