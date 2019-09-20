
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_rtl is
  port(
    clk            : in  std_ulogic;
    reset          : in  std_ulogic;
    force_feedback : in  integer;       -- -99999 to +99999
    motor_current  : in  integer;       -- Motor Current in mA
    motor_power    : out integer        -- -4799 to +4799
    );
end pid_rtl;

architecture behavioral of pid_rtl is

  constant loop_k  : integer := 9599;
  constant p_numer : integer := 0;
  constant p_denom : integer := 15;
  constant i_numer : integer := 1;
--constant i_denom : integer := 175;
  constant i_denom : integer := 500;
  constant d_numer : integer := 0;
  constant d_denom : integer := 30;

  signal tick       : std_ulogic;
  signal tick_count : integer;

  signal prop_var                 : integer;
  signal integ_var                : integer;
  signal deriv_var                : integer;
  signal prev_motor_current_error : integer;
  signal motor_power_i            : integer;

begin

  motor_power <= motor_power_i;

  sample_tick: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        tick       <= '0';
        tick_count <= 0;
      else
        if(tick_count = loop_k) then
          tick       <= '1';
          tick_count <= 0;
        else
          tick       <= '0';
          tick_count <= tick_count + 1;
        end if;
      end if;
    end if;
  end process sample_tick;

  pid_i: process(clk)
    variable motor_current_error : integer;
    variable integ_var_i         : integer;
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        motor_power_i       <= 0;
        motor_current_error := 0;
        prop_var            <= 0;
        integ_var_i         := 0;
        integ_var           <= 0;
        deriv_var           <= 0;
      elsif(tick = '1') then

        if(motor_power_i < 0) then
          motor_current_error := force_feedback + motor_current;
        else
          motor_current_error := force_feedback - motor_current;
        end if;

        prop_var    <= (motor_current_error * p_numer) / p_denom;
        integ_var_i := integ_var + ((motor_current_error * i_numer) / i_denom);
        deriv_var   <= ((motor_current_error - prev_motor_current_error) * d_numer) / d_denom;

        if(integ_var_i > 4799000) then
          integ_var_i := 4799000;
        elsif(integ_var_i < -4799000) then
          integ_var_i := -4799000;
        end if;

        integ_var <= integ_var_i;

        prev_motor_current_error <= motor_current_error;

        motor_power_i <= prop_var + integ_var_i + deriv_var;






















      end if;
    end if;
  end process pid_i;

end behavioral;
