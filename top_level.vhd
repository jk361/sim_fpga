
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;

entity top_level is
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
    mot_phc_hi    : out std_ulogic;
    mot_phc_lo    : out std_ulogic;
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
end top_level;

architecture behavioral of top_level is

  signal reset_int      : std_ulogic;
  signal shift_lights   : std_ulogic_vector(7 downto 0);
  signal uart_gear      : std_ulogic_vector(7 downto 0);
  signal sens_gear      : integer;
  signal test_op        : integer := 0;
  signal revs           : integer;
  signal revs_cfg       : integer;
  signal car_speed      : integer;
  signal oil_pressure   : integer;
  signal water_temp     : integer;
  signal lap            : integer;
  signal lap_time       : integer;
  signal best_lap_time  : integer;
  signal force_feedback : integer;
  signal motor_power    : integer;
  signal motor_current  : integer;
  signal steer_angle    : integer := 0;
  signal gear_sel_i     : std_ulogic_vector(5 downto 0);
  signal shift_rdy      : std_ulogic;
  signal gear_rdy       : std_ulogic;
  signal revs_rdy       : std_ulogic;
  signal revs_cfg_rdy   : std_ulogic;
  signal oil_p_rdy      : std_ulogic;
  signal water_t_rdy    : std_ulogic;
  signal lap_time_rdy   : std_ulogic;
  signal best_lap_rdy   : std_ulogic;
  signal ff_rdy         : std_ulogic;

begin

  mot_phc_hi <= '0';
  mot_phc_lo <= '0';

  gear_sel <= "111110" when to_unsigned(sens_gear, 3) = "001" else
              "111101" when to_unsigned(sens_gear, 3) = "010" else
              "111011" when to_unsigned(sens_gear, 3) = "011" else
              "110111" when to_unsigned(sens_gear, 3) = "100" else
              "101111" when to_unsigned(sens_gear, 3) = "101" else
              "011111" when to_unsigned(sens_gear, 3) = "110" else
              "111111";

  led <= X"00";
--led <= "0000000" & reset_int;
--led <= "10000000" when to_unsigned(sens_gear, 3) = "001" else
--       "01000000" when to_unsigned(sens_gear, 3) = "010" else
--       "00100000" when to_unsigned(sens_gear, 3) = "011" else
--       "00010000" when to_unsigned(sens_gear, 3) = "100" else
--       "00001000" when to_unsigned(sens_gear, 3) = "101" else
--       "00000100" when to_unsigned(sens_gear, 3) = "110" else
--       "00000000";

  reset_i: reset_rtl
  port map(
    clk       => clk,
    reset_in  => reset,
    reset_out => reset_int
  );

  uart_i: uart_rtl
  port map(
    clk            => clk,
    reset          => reset_int,
    uart_rxd       => uart_rxd,
    uart_txd       => open,
    shift_lights   => shift_lights,
    shift_rdy      => shift_rdy,
    uart_gear      => uart_gear,
    gear_rdy       => gear_rdy,
    revs           => revs,
    revs_rdy       => revs_rdy,
    revs_cfg       => revs_cfg,
    revs_cfg_rdy   => revs_cfg_rdy,
    car_speed      => car_speed,
    speed_rdy      => open,
    oil_pressure   => oil_pressure,
    oil_p_rdy      => oil_p_rdy,
    water_temp     => water_temp,
    water_t_rdy    => water_t_rdy,
    lap            => lap,
    lap_rdy        => open,
    lap_time       => lap_time,
    lap_time_rdy   => lap_time_rdy,
    best_lap_time  => best_lap_time,
    best_lap_rdy   => best_lap_rdy,
    force_feedback => force_feedback,
    ff_rdy         => ff_rdy
  );

  adc_intfc_i: adc_intfc_rtl
  port map(
    clk           => clk,
    reset         => reset_int,
    adc_sck       => adc_sck,
    adc_sdi       => adc_sdi,
    adc_sdo       => adc_sdo,
    adc_cs        => adc_cs,
    steer_angle   => steer_angle,
    motor_current => motor_current,
    sens_gear     => sens_gear,
    test_op       => test_op,
    uart_txd      => open
    );

  dac_intfc_i: dac_intfc_rtl
  port map(
    clk         => clk,
    reset       => reset_int,
    wheel_angle => (steer_angle / 8) + 2048,
    dac0_sck    => dac0_sck,
    dac0_sdo    => dac0_sdo,
    dac0_cs     => dac0_cs,
    dac0_ldac   => dac0_ldac,
    dac1_sck    => dac1_sck,
    dac1_sdo    => dac1_sdo,
    dac1_cs     => dac1_cs,
    dac1_ldac   => dac1_ldac
    );

  can_i: can_rtl
  port map(
    clk            => clk,
    reset          => reset_int,
    can_rxd        => can_rxd,
    can_txd        => can_txd,
    can_stb        => can_stb,
    shift_lights   => shift_lights,
    shift_rdy      => shift_rdy,
    uart_gear      => uart_gear,
    gear_rdy       => gear_rdy,
    revs           => revs,
    revs_rdy       => revs_rdy,
    revs_cfg       => revs_cfg,
    revs_cfg_rdy   => revs_cfg_rdy,
    car_speed      => car_speed,
    oil_pressure   => oil_pressure,
    oil_p_rdy      => oil_p_rdy,
    water_temp     => water_temp,
    water_t_rdy    => water_t_rdy,
    lap            => lap,
    lap_time       => lap_time,
    lap_time_rdy   => lap_time_rdy,
    best_lap_time  => best_lap_time,
    best_lap_rdy   => best_lap_rdy
    );

  motor_i: motor_rtl
  port map(
    clk         => clk,
    reset       => reset_int,
    motor_power => force_feedback,
--  motor_power => motor_power,
    mot_pha_hi  => mot_pha_hi,
    mot_pha_lo  => mot_pha_lo,
    mot_phb_hi  => mot_phb_hi,
    mot_phb_lo  => mot_phb_lo
  );

  pid_i: pid_rtl
  port map(
    clk            => clk,
    reset          => reset,
    force_feedback => force_feedback,
    motor_current  => motor_current,
    motor_power    => motor_power
    );

--  motor_power => steer_angle * (-1),

--debug_i: debug_uart_comp
--port map(
--  clk      => clk,
--  reset    => reset_int,
--  uart_txd => uart_txd,
--  input    => steer_angle
--  );

  uart_txd <= '0';

end behavioral;
