
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mcp3204_bus_model is
  port(
    adc_cs  : in  std_ulogic;
    adc_sck : in  std_ulogic;
    adc_sdo : out  std_ulogic;
    adc_sdi : in  std_ulogic;
    cha_in  : in  integer;
    chb_in  : in  integer;
    chc_in  : in  integer;
    chd_in  : in  integer
    );
end mcp3204_bus_model;

architecture behavioral of mcp3204_bus_model is

begin

  -- Stimulus process
  adc_proc: process
    constant cha_cfg : std_ulogic_vector(3 downto 0) := X"8";
    constant chb_cfg : std_ulogic_vector(3 downto 0) := X"9";
    constant chc_cfg : std_ulogic_vector(3 downto 0) := X"A";
    constant chd_cfg : std_ulogic_vector(3 downto 0) := X"B";
    variable ch_cfg  : std_ulogic_vector(3 downto 0) := X"B";
    variable cha_data : std_ulogic_vector(11 downto 0) := X"800";
    variable chb_data : std_ulogic_vector(11 downto 0) := X"800";
    variable chc_data : std_ulogic_vector(11 downto 0) := X"800";
    variable chd_data : std_ulogic_vector(11 downto 0) := X"800";
    variable ch_data  : std_ulogic_vector(11 downto 0) := X"000";
    variable flag     : std_ulogic                     := '0';
  begin

    wait until falling_edge(adc_cs);
    wait until falling_edge(adc_sck);
    wait until falling_edge(adc_sck);
    ch_cfg(3) := adc_sdi;
    wait until falling_edge(adc_sck);
    ch_cfg(2) := adc_sdi;
    wait until falling_edge(adc_sck);
    ch_cfg(1) := adc_sdi;
    wait until falling_edge(adc_sck);
    ch_cfg(0) := adc_sdi;
    wait until falling_edge(adc_sck);

    if(ch_cfg = cha_cfg) then
      ch_data := std_ulogic_vector(to_unsigned(cha_in, 12));
    elsif(ch_cfg = chb_cfg) then
      ch_data := std_ulogic_vector(to_unsigned(chb_in, 12));
    elsif(ch_cfg = chc_cfg) then
      ch_data := std_ulogic_vector(to_unsigned(chc_in, 12));
    elsif(ch_cfg = chd_cfg) then
      ch_data := std_ulogic_vector(to_unsigned(chd_in, 12));
    end if;

    wait until falling_edge(adc_sck);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(11);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(10);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(9);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(8);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(7);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(6);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(5);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(4);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(3);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(2);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(1);
    wait until falling_edge(adc_sck);
    adc_sdo <= ch_data(0);
    wait until falling_edge(adc_sck);
    adc_sdo <= 'Z';

  end process adc_proc;


end behavioral;

