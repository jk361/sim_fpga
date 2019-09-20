
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor_rtl is
  port(
    clk         : in  std_ulogic;
    reset       : in  std_ulogic;
    motor_power : in  integer;
    mot_pha_hi  : out std_ulogic;
    mot_pha_lo  : out std_ulogic;
    mot_phb_hi  : out std_ulogic;
    mot_phb_lo  : out std_ulogic
    );
end motor_rtl;

architecture behavioral of motor_rtl is

  signal count : integer := 0;

begin

  motor_i: process(clk)
    variable pwm_width : integer;
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        mot_pha_hi <= '0';
        mot_pha_lo <= '0';
        mot_phb_hi <= '0';
        mot_phb_lo <= '0';
        count      <= 0;
        pwm_width  := 0;
      else

        count <= count + 1;

        if(count = 0) then

          if((motor_power <= 4799) and (motor_power >= -4799)) then
            pwm_width := motor_power;
          else
            if(motor_power >= 4799) then
              pwm_width := 4799;
            elsif(motor_power <= -4799) then
              pwm_width := -4799;
            end if;
          end if;

          if(pwm_width > 0) then
            mot_pha_hi <= '1';
            mot_phb_hi <= '0';
            mot_pha_lo <= '0';
            mot_phb_lo <= '1';
          elsif(pwm_width < 0) then
            mot_pha_hi <= '0';
            mot_phb_hi <= '1';
            mot_pha_lo <= '1';
            mot_phb_lo <= '0';
          else
            mot_pha_hi <= '0';
            mot_phb_hi <= '0';
            mot_pha_lo <= '0';
            mot_phb_lo <= '0';
          end if;
        elsif(count = 4799) then
          count <= 0;
        elsif(count = abs(pwm_width)) then
          mot_pha_lo <= '0';
          mot_phb_lo <= '0';
        end if;
      end if;
    end if;
  end process motor_i;

end behavioral;
