
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

library work;
use work.tb_pkg.all;

use work.can_crc_pkg.all;

entity top_level_tb is
end top_level_tb;

architecture behavior of top_level_tb is

  component top_level
  port(
    clk           : in  std_ulogic;
    reset         : in  std_ulogic;
    uart_rxd      : in  std_ulogic;
    uart_txd      : out std_ulogic;
    cable_present : in  std_ulogic;
    led           : out std_ulogic_vector(7 downto 0);
    gear_sel      : out std_ulogic_vector(5 downto 0);
    can_rxd       : in  std_ulogic;
    can_txd       : out std_ulogic;
    can_stb       : out std_ulogic;
    mot_pha_hi    : out std_ulogic;
    mot_pha_lo    : out std_ulogic;
    mot_phb_hi    : out std_ulogic;
    mot_phb_lo    : out std_ulogic;
    adc_sck       : out std_ulogic;
    adc_sdi       : in  std_ulogic;
    adc_sdo       : out std_ulogic;
    adc_cs        : out std_ulogic;
    dac0_sck      : out std_ulogic;
    dac0_sdo      : out std_ulogic;
    dac0_cs       : out std_ulogic;
    dac0_ldac     : out std_ulogic;
    dac1_sck      : out std_ulogic;
    dac1_sdo      : out std_ulogic;
    dac1_cs       : out std_ulogic;
    dac1_ldac     : out std_ulogic
    );
  end component top_level;

  component mcp3204_bus_model
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
  end component mcp3204_bus_model;

  component can_monitor
  port(
    can_stb       : in  std_ulogic;
    can_txd       : in  std_ulogic;
    can_rxd       : out std_ulogic;
    crc_fail      : out std_ulogic;
    shift_lights  : out integer;
    uart_gear     : out integer;
    revs          : out integer;
    revs_cfg      : out integer;
    car_speed     : out integer;
    oil_pressure  : out integer;
    water_temp    : out integer;
    lap           : out integer;
    lap_time      : out integer;
    best_lap_time : out integer
    );
  end component can_monitor;

  component motor_model is
  port(
    mot_pha_hi    : in std_ulogic;
    mot_pha_lo    : in std_ulogic;
    mot_phb_hi    : in std_ulogic;
    mot_phb_lo    : in std_ulogic;
    motor_current : out integer
    );
  end component motor_model;

  file output_file       : text;
  constant output_period : time       := 100 us;
  signal output_time     : integer    := 0;
  signal write_file      : std_ulogic := '0';
  signal exit_loop       : std_ulogic := '1';

  type can_data_buf_type is array (0 to 7) of std_ulogic_vector(7 downto 0);
  signal calc_crc : std_ulogic_vector(14 downto 0) := (others => '0');
  signal test_number : integer := 0;

  --Inputs
  signal clk      : std_ulogic := '0';
  signal reset    : std_ulogic := '1';
  signal uart_rxd : std_ulogic := '1';
  signal can_rxd  : std_ulogic := '0';
  signal crc_fail : std_ulogic := '0';
  signal adc_sdi  : std_ulogic := 'Z';

  --Outputs
  signal uart_txd      : std_ulogic;
  signal led           : std_ulogic_vector(7 downto 0);
  signal gear_sel      : std_ulogic_vector(5 downto 0);
  signal can_txd       : std_ulogic;
  signal cable_present : std_ulogic;
  signal can_stb       : std_ulogic;
  signal mot_pha_hi    : std_ulogic;
  signal mot_pha_lo    : std_ulogic;
  signal mot_phb_hi    : std_ulogic;
  signal mot_phb_lo    : std_ulogic;
  signal adc_sck       : std_ulogic;
  signal adc_sdo       : std_ulogic;
  signal adc_cs        : std_ulogic;
  signal dac0_sck      : std_ulogic;
  signal dac0_sdo      : std_ulogic;
  signal dac0_cs       : std_ulogic;
  signal dac0_ldac     : std_ulogic;
  signal dac1_sck      : std_ulogic;
  signal dac1_sdo      : std_ulogic;
  signal dac1_cs       : std_ulogic;
  signal dac1_ldac     : std_ulogic;

  signal inbyte : std_ulogic_vector(7 downto 0) := X"00";

  signal steer_angle   : integer := 0;
  signal motor_current : integer := 0;

  -- Clock period definitions
  constant clk_period : time := 20833 ps;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: top_level
  port map(
    clk           => clk,
    reset         => reset,
    uart_rxd      => uart_rxd,
    uart_txd      => uart_txd,
    cable_present => cable_present,
    led           => led,
    gear_sel      => gear_sel,
    can_rxd       => can_rxd,
    can_txd       => can_txd,
    can_stb       => can_stb,
    mot_pha_hi    => mot_pha_hi,
    mot_pha_lo    => mot_pha_lo,
    mot_phb_hi    => mot_phb_hi,
    mot_phb_lo    => mot_phb_lo,
    adc_sck       => adc_sck,
    adc_sdi       => adc_sdi,
    adc_sdo       => adc_sdo,
    adc_cs        => adc_cs,
    dac0_sck      => dac0_sck,
    dac0_sdo      => dac0_sdo,
    dac0_cs       => dac0_cs,
    dac0_ldac     => dac0_ldac,
    dac1_sck      => dac1_sck,
    dac1_sdo      => dac1_sdo,
    dac1_cs       => dac1_cs,
    dac1_ldac     => dac1_ldac
    );

  dac_i: mcp3204_bus_model
  port map(
    adc_cs  => adc_cs,
    adc_sck => adc_sck,
    adc_sdo => adc_sdi,
    adc_sdi => adc_sdo,
    cha_in  => 0,
    chb_in  => motor_current,
    chc_in  => steer_angle,
    chd_in  => 0
    );

  motor_i: motor_model
  port map(
    mot_pha_hi    => mot_pha_hi,
    mot_pha_lo    => mot_pha_lo,
    mot_phb_hi    => mot_phb_hi,
    mot_phb_lo    => mot_phb_lo,
    motor_current => motor_current
    );

  can_i: can_monitor
  port map(
    can_stb       => can_stb,
    can_txd       => can_txd,
    can_rxd       => can_rxd,
    crc_fail      => crc_fail,
    shift_lights  => open,
    uart_gear     => open,
    revs          => open,
    revs_cfg      => open,
    car_speed     => open,
    oil_pressure  => open,
    water_temp    => open,
    lap           => open,
    lap_time      => open,
    best_lap_time => open
    );

  reset_proc: process
  begin
    -- hold reset state for 100 ns.
    reset <= '0';
    wait for 100 ns;
    reset <= '1';
    wait;
  end process;

  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  adc_process :process
  begin

    steer_angle <= 2048;
    wait for 300 us;

    loop

      if(steer_angle = 0) then
        steer_angle <= 4095;
      else
        steer_angle <= steer_angle - 1;
      end if;

      wait for 200 us;

    end loop;

  end process;

  -- Stimulus process
  stim_proc: process
  begin

    write_file <= '1';

    wait for 5 ms;

    test_number <= 1;
    send_revs_scale(X"30", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"31", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"32", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"33", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"34", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"35", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"36", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"37", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"38", uart_rxd);
--  wait for 1 ms;
--  send_revs_scale(X"39", uart_rxd);
    wait for 5 ms;

--  test_number <= 2;
--  send_shift_lights(X"30", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"31", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"32", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"33", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"34", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"35", uart_rxd);
--  wait for 1 ms;
--  send_shift_lights(X"30", uart_rxd);
--  wait for 5 ms;

--  test_number <= 3;
--  send_uart_gear(0, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(1, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(2, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(3, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(4, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(5, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(6, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(7, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(8, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(9, uart_rxd);
--  wait for 1 ms;
--  send_uart_gear(0, uart_rxd);
--  wait for 5 ms;
--
--  test_number <= 4;
--  send_revs_speed(0, 0, uart_rxd);
--  wait for 1 ms;
--  send_revs_speed(6800, 120, uart_rxd);
--  wait for 1 ms;
--  send_revs_speed(65535, 999, uart_rxd);
--  wait for 5 ms;
--
--  test_number <= 5;
--  send_oil_p(0, uart_rxd);
--  wait for 1 ms;
--  send_oil_p(127, uart_rxd);
--  wait for 1 ms;
--  send_oil_p(255, uart_rxd);
--  wait for 1 ms;
--  send_oil_p(0, uart_rxd);
--  wait for 5 ms;
--
--  test_number <= 6;
--  send_water_t(0, uart_rxd);
--  wait for 1 ms;
--  send_water_t(127, uart_rxd);
--  wait for 1 ms;
--  send_water_t(255, uart_rxd);
--  wait for 1 ms;
--  send_water_t(0, uart_rxd);
--  wait for 5 ms;
--
--  test_number <= 7;
--  send_lap_time(0, 0, uart_rxd);
--  wait for 1 ms;
--  send_lap_time(11111, 111, uart_rxd);
--  wait for 1 ms;
--  send_lap_time(49999, 127, uart_rxd);
--  wait for 1 ms;
--  send_lap_time(99999, 255, uart_rxd);
--  wait for 1 ms;
--  send_lap_time(0, 0, uart_rxd);
--  wait for 5 ms;
--
--  test_number <= 8;
--  send_best_lap_time(0, 0, uart_rxd);
--  wait for 1 ms;
--  send_best_lap_time(11111, 111, uart_rxd);
--  wait for 1 ms;
--  send_best_lap_time(49999, 127, uart_rxd);
--  wait for 1 ms;
--  send_best_lap_time(99999, 255, uart_rxd);
--  wait for 1 ms;
--  send_best_lap_time(0, 0, uart_rxd);
--  wait for 5 ms;

    test_number <= 9;
    send_force_feedback(0, uart_rxd);
    wait for 5 ms;
    send_force_feedback(1000, uart_rxd);
    wait for 50 ms;
    send_force_feedback(0, uart_rxd);
    wait for 50 ms;
    send_force_feedback(-1000, uart_rxd);
    wait for 50 ms;
    send_force_feedback(0, uart_rxd);
    wait for 50 ms;
--  send_force_feedback(4798, uart_rxd);
--  wait for 50 ms;
--  send_force_feedback(-4798, uart_rxd);
--  wait for 50 ms;
--  send_force_feedback(1, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(-1, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(2, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(-2, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(-49999, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(49999, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(-99999, uart_rxd);
--  wait for 1 ms;
--  send_force_feedback(99999, uart_rxd);
--  wait for 5 ms;

    write_file <= '0';

    wait;
  end process stim_proc;


  output_file_proc: process
    variable output_line : line;
  begin

    file_open(output_file, "output_file.csv", write_mode);

    wait until (write_file = '1');

    while(exit_loop = '1') loop
      write(output_line, output_time, left, 16);
      write(output_line, ", ", right, 2);
      write(output_line, motor_current, right, 8);
      writeline(output_file, output_line);
      wait for output_period;

      if(write_file = '0') then
        exit_loop <= '0';
        file_close(output_file);
      end if;

    end loop;

  end process output_file_proc;


  time_proc: process
  begin
    output_time <= output_time + 100;
    wait for output_period;
  end process time_proc;

end;
