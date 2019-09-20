
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_pkg is

  procedure send_uart_byte(inbyte : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic);
  procedure send_revs_scale(cfg_byte : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic);
  procedure send_revs_speed(revs : in integer; speed : in integer; signal uart_rxd : out std_ulogic);
  procedure send_shift_lights(shift_lights : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic);
  procedure send_uart_gear(uart_gear : in integer; signal uart_rxd : out std_ulogic);
  procedure send_oil_p(oil_p : in integer; signal uart_rxd : out std_ulogic);
  procedure send_water_t(water_t : in integer; signal uart_rxd : out std_ulogic);
  procedure send_lap_time(lap_time : in integer; lap_no : in integer; signal uart_rxd : out std_ulogic);
  procedure send_best_lap_time(lap_time : in integer; lap_no : in integer; signal uart_rxd : out std_ulogic);
  procedure send_force_feedback(force_feedback : in integer; signal uart_rxd : out std_ulogic);
  procedure can_wait_bit(in_bit : in std_ulogic; signal stuff_reg : inout std_ulogic_vector(4 downto 0));

end tb_pkg;

package body tb_pkg is

  constant baud_period     : time := 2000 ns;
  constant can_baud_period : time := 1000 ns;

  procedure send_uart_byte(inbyte : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic) is
  begin
    uart_rxd <= '0';
    wait for baud_period;
    uart_rxd <= inbyte(0);
    wait for baud_period;
    uart_rxd <= inbyte(1);
    wait for baud_period;
    uart_rxd <= inbyte(2);
    wait for baud_period;
    uart_rxd <= inbyte(3);
    wait for baud_period;
    uart_rxd <= inbyte(4);
    wait for baud_period;
    uart_rxd <= inbyte(5);
    wait for baud_period;
    uart_rxd <= inbyte(6);
    wait for baud_period;
    uart_rxd <= inbyte(7);
    wait for baud_period;
    uart_rxd <= '1';
    wait for baud_period * 2;
  end procedure send_uart_byte;

  procedure send_revs_scale(cfg_byte : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic) is
  begin
    if((cfg_byte > X"2F") and (cfg_byte < X"39")) then
      send_uart_byte(X"58", uart_rxd);
      send_uart_byte(cfg_byte, uart_rxd);
    end if;
  end procedure send_revs_scale;

  procedure send_revs_speed(revs : in integer; speed : in integer; signal uart_rxd : out std_ulogic) is
    variable revs_i  : integer;
    variable revs_0  : integer;
    variable revs_1  : integer;
    variable revs_2  : integer;
    variable revs_3  : integer;
    variable speed_i : integer;
    variable speed_0 : integer;
    variable speed_1 : integer;
  begin
    if((revs >= 0) and (revs < 65536)) then
      revs_i := revs;
      revs_0 := 0;
      revs_1 := 0;
      revs_2 := 0;
      revs_3 := 0;

      while(revs_i > 9999) loop
        revs_0 := revs_0 + 1;
        revs_i := revs_i - 10000;
      end loop;

      while(revs_i > 999) loop
        revs_1 := revs_1 + 1;
        revs_i := revs_i - 1000;
      end loop;

      while(revs_i > 99) loop
        revs_2 := revs_2 + 1;
        revs_i := revs_i - 100;
      end loop;

      while(revs_i > 9) loop
        revs_3 := revs_3 + 1;
        revs_i := revs_i - 10;
      end loop;

      send_uart_byte(X"52", uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(revs_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(revs_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(revs_2 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(revs_3 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(revs_i + 48, 8)), uart_rxd);

    end if;

    if((speed >= 0) and (speed < 1000)) then
      speed_i := speed;
      speed_0 := 0;
      speed_1 := 0;

      while(speed_i > 99) loop
        speed_0 := speed_0 + 1;
        speed_i := speed_i - 100;
      end loop;

      while(speed_i > 9) loop
        speed_1 := speed_1 + 1;
        speed_i := speed_i - 10;
      end loop;

      send_uart_byte(std_ulogic_vector(to_unsigned(speed_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(speed_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(speed_i + 48, 8)), uart_rxd);
    end if;
  end procedure send_revs_speed;

  procedure send_shift_lights(shift_lights : in std_ulogic_vector(7 downto 0); signal uart_rxd : out std_ulogic) is
  begin
    if((shift_lights > X"2F") and (shift_lights < X"36")) then
      send_uart_byte(X"4C", uart_rxd);
      send_uart_byte(shift_lights, uart_rxd);
    end if;
  end procedure send_shift_lights;

  procedure send_uart_gear(uart_gear : in integer; signal uart_rxd : out std_ulogic) is
  begin
    if((uart_gear >= 0) and (uart_gear < 10)) then
      send_uart_byte(X"47", uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(uart_gear + 48, 8)), uart_rxd);
    end if;
  end procedure send_uart_gear;

  procedure send_oil_p(oil_p : in integer; signal uart_rxd : out std_ulogic) is
    variable oil_p_i   : integer;
    variable oil_p_0   : integer;
    variable oil_p_1   : integer;
  begin

    if((oil_p >= 0) and (oil_p < 256)) then
      oil_p_i   := oil_p  ;
      oil_p_0   := 0  ;
      oil_p_1   := 0  ;

      while(oil_p_i > 99) loop
        oil_p_0 := oil_p_0 + 1;
        oil_p_i := oil_p_i - 100;
      end loop;

      while(oil_p_i > 9) loop
        oil_p_1 := oil_p_1 + 1;
        oil_p_i := oil_p_i - 10;
      end loop;

      send_uart_byte(X"4F", uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(oil_p_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(oil_p_1 + 48, 8)), uart_rxd);
    end if;
  end procedure send_oil_p;

  procedure send_water_t(water_t : in integer; signal uart_rxd : out std_ulogic) is
    variable water_t_i : integer;
    variable water_t_0 : integer;
    variable water_t_1 : integer;
  begin

    if((water_t >= 0) and (water_t < 256)) then
      water_t_i := water_t;
      water_t_0 := 0;
      water_t_1 := 0;

      while(water_t_i > 99) loop
        water_t_0 := water_t_0 + 1;
        water_t_i := water_t_i - 100;
      end loop;

      while(water_t_i > 9) loop
        water_t_1 := water_t_1 + 1;
        water_t_i := water_t_i - 10;
      end loop;

      send_uart_byte(X"45", uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(water_t_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(water_t_1 + 48, 8)), uart_rxd);
    end if;
  end procedure send_water_t;

  procedure send_lap_time(lap_time : in integer; lap_no : in integer; signal uart_rxd : out std_ulogic) is
    variable lap_time_i : integer;
    variable lap_time_0 : integer;
    variable lap_time_1 : integer;
    variable lap_time_2 : integer;
    variable lap_time_3 : integer;
    variable lap_time_4 : integer;
    variable lap_no_i   : integer;
    variable lap_no_0   : integer;
    variable lap_no_1   : integer;
    variable lap_no_2   : integer;
  begin
    if((lap_time >= 0) and (lap_time < 1000000)  and (lap_no >= 0)  and (lap_no < 256)) then
      lap_time_i := lap_time;
      lap_time_0 := 0;
      lap_time_1 := 0;
      lap_time_2 := 0;
      lap_time_3 := 0;
      lap_time_4 := 0;
      lap_no_i   := lap_no;
      lap_no_0   := 0;
      lap_no_1   := 0;

      while(lap_time_i > 99999) loop
        lap_time_0 := lap_time_0 + 1;
        lap_time_i := lap_time_i - 100000;
      end loop;

      while(lap_time_i > 9999) loop
        lap_time_1 := lap_time_1 + 1;
        lap_time_i := lap_time_i - 10000;
      end loop;

      while(lap_time_i > 999) loop
        lap_time_2 := lap_time_2 + 1;
        lap_time_i := lap_time_i - 1000;
      end loop;

      while(lap_time_i > 99) loop
        lap_time_3 := lap_time_3 + 1;
        lap_time_i := lap_time_i - 100;
      end loop;

      while(lap_time_i > 9) loop
        lap_time_4 := lap_time_4 + 1;
        lap_time_i := lap_time_i - 10;
      end loop;

      while(lap_no_i > 99) loop
        lap_no_0 := lap_no_0 + 1;
        lap_no_i := lap_no_i - 100;
      end loop;

      while(lap_no_i > 9) loop
        lap_no_1 := lap_no_1 + 1;
        lap_no_i := lap_no_i - 10;
      end loop;

      send_uart_byte(X"54", uart_rxd);
--    send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_2 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_3 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_4 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_i + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_i + 48, 8)), uart_rxd);
    end if;
  end procedure send_lap_time;

  procedure send_best_lap_time(lap_time : in integer; lap_no : in integer; signal uart_rxd : out std_ulogic) is
    variable lap_time_i : integer;
    variable lap_time_0 : integer;
    variable lap_time_1 : integer;
    variable lap_time_2 : integer;
    variable lap_time_3 : integer;
    variable lap_time_4 : integer;
    variable lap_no_i   : integer;
    variable lap_no_0   : integer;
    variable lap_no_1   : integer;
    variable lap_no_2   : integer;
  begin
    if((lap_time >= 0) and (lap_time < 1000000)  and (lap_no >= 0)  and (lap_no < 256)) then
      lap_time_i := lap_time;
      lap_time_0 := 0;
      lap_time_1 := 0;
      lap_time_2 := 0;
      lap_time_3 := 0;
      lap_time_4 := 0;
      lap_no_i   := lap_no;
      lap_no_0   := 0;
      lap_no_1   := 0;

      while(lap_time_i > 99999) loop
        lap_time_0 := lap_time_0 + 1;
        lap_time_i := lap_time_i - 100000;
      end loop;

      while(lap_time_i > 9999) loop
        lap_time_1 := lap_time_1 + 1;
        lap_time_i := lap_time_i - 10000;
      end loop;

      while(lap_time_i > 999) loop
        lap_time_2 := lap_time_2 + 1;
        lap_time_i := lap_time_i - 1000;
      end loop;

      while(lap_time_i > 99) loop
        lap_time_3 := lap_time_3 + 1;
        lap_time_i := lap_time_i - 100;
      end loop;

      while(lap_time_i > 9) loop
        lap_time_4 := lap_time_4 + 1;
        lap_time_i := lap_time_i - 10;
      end loop;

      while(lap_no_i > 99) loop
        lap_no_0 := lap_no_0 + 1;
        lap_no_i := lap_no_i - 100;
      end loop;

      while(lap_no_i > 9) loop
        lap_no_1 := lap_no_1 + 1;
        lap_no_i := lap_no_i - 10;
      end loop;

      send_uart_byte(X"42", uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_2 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_3 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_4 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_time_i + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_0 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_1 + 48, 8)), uart_rxd);
      send_uart_byte(std_ulogic_vector(to_unsigned(lap_no_i + 48, 8)), uart_rxd);
    end if;
  end procedure send_best_lap_time;

  procedure send_force_feedback(force_feedback : in integer; signal uart_rxd : out std_ulogic) is
    variable force_feedback_i : integer;
    variable force_feedback_0 : integer;
    variable force_feedback_1 : integer;
    variable force_feedback_2 : integer;
    variable force_feedback_3 : integer;
    variable force_feedback_4 : integer;
  begin

    send_uart_byte(X"46", uart_rxd);

    if(force_feedback < 0) then
      send_uart_byte(X"2D", uart_rxd);
    else
      send_uart_byte(X"2B", uart_rxd);
    end if;

    force_feedback_i := abs(force_feedback);
    force_feedback_0 := 0;
    force_feedback_1 := 0;
    force_feedback_2 := 0;
    force_feedback_3 := 0;
    force_feedback_4 := 0;

    while(force_feedback_i > 99999) loop
      force_feedback_0 := force_feedback_0 + 1;
      force_feedback_i := force_feedback_i - 100000;
    end loop;

    while(force_feedback_i > 9999) loop
      force_feedback_1 := force_feedback_1 + 1;
      force_feedback_i := force_feedback_i - 10000;
    end loop;

    while(force_feedback_i > 999) loop
      force_feedback_2 := force_feedback_2 + 1;
      force_feedback_i := force_feedback_i - 1000;
    end loop;

    while(force_feedback_i > 99) loop
      force_feedback_3 := force_feedback_3 + 1;
      force_feedback_i := force_feedback_i - 100;
    end loop;

    while(force_feedback_i > 9) loop
      force_feedback_4 := force_feedback_4 + 1;
      force_feedback_i := force_feedback_i - 10;
    end loop;

    send_uart_byte(std_ulogic_vector(to_unsigned(force_feedback_1 + 48, 8)), uart_rxd);
    send_uart_byte(std_ulogic_vector(to_unsigned(force_feedback_2 + 48, 8)), uart_rxd);
    send_uart_byte(std_ulogic_vector(to_unsigned(force_feedback_3 + 48, 8)), uart_rxd);
    send_uart_byte(std_ulogic_vector(to_unsigned(force_feedback_4 + 48, 8)), uart_rxd);
    send_uart_byte(std_ulogic_vector(to_unsigned(force_feedback_i + 48, 8)), uart_rxd);
  end procedure send_force_feedback;

  procedure can_wait_bit(in_bit : in std_ulogic; signal stuff_reg : inout std_ulogic_vector(4 downto 0)) is
  begin

    stuff_reg(4) <= stuff_reg(3);
    stuff_reg(3) <= stuff_reg(2);
    stuff_reg(2) <= stuff_reg(1);
    stuff_reg(1) <= stuff_reg(0);
    stuff_reg(0) <= in_bit;

    wait for can_baud_period;

    if(stuff_reg = "00000") then
      stuff_reg(4) <= stuff_reg(3);
      stuff_reg(3) <= stuff_reg(2);
      stuff_reg(2) <= stuff_reg(1);
      stuff_reg(1) <= stuff_reg(0);
      stuff_reg(0) <= '1';
      wait for can_baud_period;
    elsif(stuff_reg = "11111") then
      stuff_reg(4) <= stuff_reg(3);
      stuff_reg(3) <= stuff_reg(2);
      stuff_reg(2) <= stuff_reg(1);
      stuff_reg(1) <= stuff_reg(0);
      stuff_reg(0) <= '0';
      wait for can_baud_period;
    end if;
  end procedure can_wait_bit;

end tb_pkg;
