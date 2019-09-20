
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_intfc_rtl is
  port(
    clk         : in  std_ulogic;
    reset       : in  std_ulogic;
    wheel_angle : in  integer;
    dac0_sck    : out std_ulogic;
    dac0_sdo    : out std_ulogic;
    dac0_cs     : out std_ulogic;
    dac0_ldac   : out std_ulogic;
    dac1_sck    : out std_ulogic;
    dac1_sdo    : out std_ulogic;
    dac1_cs     : out std_ulogic;
    dac1_ldac   : out std_ulogic
    );
end dac_intfc_rtl;

architecture behavioral of dac_intfc_rtl is

  constant dac0_cfg : std_ulogic_vector(3 downto 0) := X"3";

  type tx_state_type is (idle, c0, c1, c2, c3, c4, c5, c6, c7, c8, c9,
                         d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11,
                         w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11,
                         s0, s1, s2, s3, s4, s5, s6);

  signal tx_state : tx_state_type;

  signal count        : integer := 0;
  signal tick         : std_ulogic;
  signal tick_count   : integer;
  signal output_latch : std_ulogic_vector(11 downto 0);

begin

  tx_tick: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        tick       <= '0';
        tick_count <= 0;
      else
        if(tick_count = 479999) then
          tick       <= '1';
          tick_count <= 0;
        else
          tick       <= '0';
          tick_count <= tick_count + 1;
        end if;
      end if;
    end if;
  end process tx_tick;

  dac_i: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        dac0_sck     <= '0';
        dac0_sdo     <= '0';
        dac0_cs      <= '1';
        dac0_ldac    <= '1';
        dac1_sck     <= '0';
        dac1_sdo     <= '0';
        dac1_cs      <= '1';
        dac1_ldac    <= '1';
        output_latch <= (others => '0');
      else

        case tx_state is

          when idle =>
            if(tick = '1') then
              tx_state <= c0;
              dac0_cs  <= '0';

              if((wheel_angle <= 4095) and (wheel_angle >= 0)) then
                output_latch <= std_ulogic_vector(to_unsigned(wheel_angle, 12));
              end if;
            end if;

          when c0 =>
            tx_state <= c1;
            dac0_sdo <= dac0_cfg(3);

          when c1 =>
            tx_state <= c2;
            dac0_sck <= '1';

          when c2 =>
            tx_state <= c3;
            dac0_sdo <= dac0_cfg(2);
            dac0_sck <= '0';

          when c3 =>
            tx_state <= c4;
            dac0_sck <= '1';

          when c4 =>
            tx_state <= c5;
            dac0_sdo <= dac0_cfg(1);
            dac0_sck <= '0';

          when c5 =>
            tx_state <= c6;
            dac0_sck <= '1';

          when c6 =>
            tx_state <= c7;
            dac0_sdo <= dac0_cfg(0);
            dac0_sck <= '0';

          when c7 =>
            tx_state <= c8;

          when c8 =>
            tx_state <= c9;
            dac0_sck <= '1';

          when c9 =>
            tx_state <= d11;

          when d11 =>
            tx_state <= w11;
            dac0_sdo <= output_latch(11);
            dac0_sck <= '0';

          when w11 =>
            tx_state <= d10;
            dac0_sck <= '1';

          when d10 =>
            tx_state <= w10;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(10);

          when w10 =>
            tx_state <= d9;
            dac0_sck <= '1';

          when d9 =>
            tx_state <= w9;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(9);

          when w9 =>
            tx_state <= d8;
            dac0_sck <= '1';

          when d8 =>
            tx_state <= w8;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(8);

          when w8 =>
            tx_state <= d7;
            dac0_sck <= '1';

          when d7 =>
            tx_state <= w7;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(7);

          when w7 =>
            tx_state <= d6;
            dac0_sck <= '1';

          when d6 =>
            tx_state <= w6;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(6);

          when w6 =>
            tx_state <= d5;
            dac0_sck <= '1';

          when d5 =>
            tx_state <= w5;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(5);

          when w5 =>
            tx_state <= d4;
            dac0_sck <= '1';

          when d4 =>
            tx_state <= w4;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(4);

          when w4 =>
            tx_state <= d3;
            dac0_sck <= '1';

          when d3 =>
            tx_state <= w3;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(3);

          when w3 =>
            tx_state <= d2;
            dac0_sck <= '1';

          when d2 =>
            tx_state <= w2;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(2);

          when w2 =>
            tx_state <= d1;
            dac0_sck <= '1';

          when d1 =>
            tx_state <= w1;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(1);

          when w1 =>
            tx_state <= d0;
            dac0_sck <= '1';

          when d0 =>
            tx_state <= w0;
            dac0_sck <= '0';
            dac0_sdo <= output_latch(0);

          when w0 =>
            tx_state <= s0;
            dac0_sck <= '1';

          when s0 =>
            tx_state <= s1;
            dac0_sck <= '0';

          when s1 =>
            tx_state <= s2;
            dac0_cs  <= '1';

          when s2 =>
            tx_state <= s3;
            dac0_sck <= '1';

          when s3 =>
            tx_state  <= s4;
            dac0_ldac <= '0';

          when s4 =>
            tx_state <= s5;
            dac0_sck <= '0';

          when s5 =>
            tx_state  <= s6;
            dac0_ldac <= '1';

          when s6 =>
            tx_state  <= idle;
            dac0_ldac <= '1';

          when others =>
            tx_state <= idle;

        end case;

      end if;
    end if;
  end process dac_i;

end behavioral;
