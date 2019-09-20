
library ieee;
use ieee.std_logic_1164.all;

package can_crc_pkg is

  procedure can_crc_calc(signal crcreg : inout std_ulogic_vector(14 downto 0); din : in std_ulogic);

end can_crc_pkg;

package body can_crc_pkg is

  procedure can_crc_calc(signal crcreg : inout std_ulogic_vector(14 downto 0); din : in std_ulogic) is
  begin

    crcreg(0)  <= crcreg(14) xor din;
    crcreg(1)  <= crcreg(0);
    crcreg(2)  <= crcreg(1);
    crcreg(3)  <= crcreg(2) xor crcreg(14) xor din;
    crcreg(4)  <= crcreg(3) xor crcreg(14) xor din;
    crcreg(5)  <= crcreg(4);
    crcreg(6)  <= crcreg(5);
    crcreg(7)  <= crcreg(6) xor crcreg(14) xor din;
    crcreg(8)  <= crcreg(7) xor crcreg(14) xor din;
    crcreg(9)  <= crcreg(8);
    crcreg(10) <= crcreg(9) xor crcreg(14) xor din;
    crcreg(11) <= crcreg(10);
    crcreg(12) <= crcreg(11);
    crcreg(13) <= crcreg(12);
    crcreg(14) <= crcreg(13) xor crcreg(14) xor din;

  end procedure can_crc_calc;

end can_crc_pkg;
