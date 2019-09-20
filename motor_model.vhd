
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor_model is
  port(
    mot_pha_hi    : in std_ulogic;
    mot_pha_lo    : in std_ulogic;
    mot_phb_hi    : in std_ulogic;
    mot_phb_lo    : in std_ulogic;
    motor_current : out integer
    );
end motor_model;

architecture behavioral of motor_model is

  type duration_buf_type is array (0 to 9) of integer;
  signal duration_buf : duration_buf_type;

  constant drive_supply     : integer := 18000;  -- 18.000 V
  constant motor_resistance : integer := 1000;   -- 1.000  ohm

  signal mot_pha_lo_prev : std_ulogic := '0';
  signal mot_phb_lo_prev : std_ulogic := '0';
  signal pha_count       : integer := 0;
  signal phb_count       : integer := 0;
  signal hi_duration     : integer := 0;

begin

  pwm_count_proc: process
    variable ph_hi : integer;
    variable pha_hi : integer;
    variable phb_hi : integer;
  begin
    mot_pha_lo_prev <= mot_pha_lo;
    mot_phb_lo_prev <= mot_phb_lo;

    if((mot_phb_lo = '1') and (mot_phb_lo_prev = '0')) then
      phb_count <= 0;
    elsif((mot_phb_lo = '0') and (mot_phb_lo_prev = '1')) then
      phb_hi := phb_count;
    else
      if(phb_count >= 4800) then
        phb_hi := 0;
      else
        phb_count <= phb_count + 1;
      end if;
    end if;

    if((mot_pha_lo = '1') and (mot_pha_lo_prev = '0')) then
      pha_count <= 0;
    elsif((mot_pha_lo = '0') and (mot_pha_lo_prev = '1')) then
      pha_hi := pha_count;
    else
      if(pha_count >= 4800) then
        pha_hi := 0;
      else
        pha_count <= pha_count + 1;
      end if;
    end if;

    ph_hi := pha_hi + phb_hi;

    if(ph_hi >= 4799) then
      hi_duration <= 4799;
    elsif(ph_hi <= 0) then
      hi_duration <= 0;
    else
      hi_duration <= ph_hi;
    end if;

    wait for 20833 ps;

  end process pwm_count_proc;

  model_proc: process
    variable duty_cycle : integer := 0;
  begin

    duty_cycle := (hi_duration * 100000) / 4799;

    duration_buf(9) <= duration_buf(8);
    duration_buf(8) <= duration_buf(7);
    duration_buf(7) <= duration_buf(6);
    duration_buf(6) <= duration_buf(5);
    duration_buf(5) <= duration_buf(4);
    duration_buf(4) <= duration_buf(3);
    duration_buf(3) <= duration_buf(2);
    duration_buf(2) <= duration_buf(1);
    duration_buf(1) <= duration_buf(0);
    duration_buf(0) <= duty_cycle;

    motor_current <= (((duration_buf(0) + duration_buf(1) + duration_buf(2) + duration_buf(3) + duration_buf(4) + duration_buf(5) + duration_buf(6) + duration_buf(7) + duration_buf(8) + duty_cycle) * 18) / 1000);

   wait for 1 ns;

  end process model_proc;




end behavioral;

