library verilog;
use verilog.vl_types.all;
entity Histo is
    port(
        iPclk           : in     vl_logic;
        iY_Cont         : in     vl_logic_vector(15 downto 0);
        iX_Cont         : in     vl_logic_vector(15 downto 0);
        Dval            : in     vl_logic;
        Fval            : in     vl_logic;
        Grey            : in     vl_logic_vector(11 downto 0);
        Gr_Out_His1     : out    vl_logic_vector(15 downto 0);
        Gr_Out_His2     : out    vl_logic_vector(15 downto 0);
        Gr_Out_Cum1     : out    vl_logic_vector(15 downto 0);
        Gr_Out_Cum2     : out    vl_logic_vector(15 downto 0);
        stateOut        : out    vl_logic_vector(1 downto 0)
    );
end Histo;
