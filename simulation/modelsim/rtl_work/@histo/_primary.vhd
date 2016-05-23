library verilog;
use verilog.vl_types.all;
entity Histo is
    port(
        iPclk           : in     vl_logic;
        iY_cont         : in     vl_logic_vector(15 downto 0);
        iX_cont         : in     vl_logic_vector(15 downto 0);
        Dval            : in     vl_logic;
        Fval            : in     vl_logic;
        Grey            : in     vl_logic_vector(7 downto 0);
        Gr_Out_His      : out    vl_logic_vector(7 downto 0);
        Gr_Out_Cum      : out    vl_logic_vector(7 downto 0);
        stateOut        : out    vl_logic_vector(1 downto 0)
    );
end Histo;
