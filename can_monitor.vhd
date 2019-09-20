
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.can_crc_pkg.all;
use work.tb_pkg.all;

entity can_monitor is
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
end can_monitor;

architecture behavioral of can_monitor is

  constant baud_period : time := 1000 ns;

  type can_data_buf_type is array (0 to 7) of std_ulogic_vector(7 downto 0);
  signal rx_fifo : can_data_buf_type;

  signal shift_lights_i  : integer := 0;
  signal uart_gear_i     : integer := 0;
  signal revs_i          : integer := 0;
  signal revs_cfg_i      : integer := 0;
  signal car_speed_i     : integer := 0;
  signal oil_pressure_i  : integer := 0;
  signal water_temp_i    : integer := 0;
  signal lap_i           : integer := 0;
  signal lap_time_i      : integer := 0;
  signal best_lap_time_i : integer := 0;

  signal rx_arb_field  : std_ulogic_vector(10 downto 0);
  signal rx_ctrl_field : std_ulogic_vector(2 downto 0);
  signal rx_dlen_field : std_ulogic_vector(3 downto 0);

  signal can_rxd_i      : std_ulogic;
  signal stuff_reg      : std_ulogic_vector(4 downto 0) := (others => '1');
  signal calc_crc       : std_ulogic_vector(14 downto 0) := (others => '0');
  signal calc_crc_field : std_ulogic_vector(14 downto 0);
  signal capt_crc_field : std_ulogic_vector(14 downto 0);

begin

  can_rxd_i     <= can_txd when can_stb = '0' else 'Z';
  shift_lights  <= shift_lights_i;
  uart_gear     <= uart_gear_i;
  revs          <= revs_i;
  revs_cfg      <= revs_cfg_i;
  car_speed     <= car_speed_i;
  oil_pressure  <= oil_pressure_i;
  water_temp    <= water_temp_i;
  lap           <= lap_i;
  lap_time      <= lap_time_i;
  best_lap_time <= best_lap_time_i;

  can_proc: process
    constant c_arb_revs         : std_ulogic_vector(11 downto 0) := X"401"; -- Revs, Velocity & Gear
    constant c_arb_temp         : std_ulogic_vector(11 downto 0) := X"402"; -- Water Temp & Oil Pressure
    constant c_arb_temp_cfg     : std_ulogic_vector(11 downto 0) := X"404"; -- Pressure / Temp Config.
    constant c_arb_shift_lights : std_ulogic_vector(11 downto 0) := X"405"; -- Shift Lights
    constant c_arb_revs_cfg     : std_ulogic_vector(11 downto 0) := X"406"; -- LCD Rev Scale
    constant c_arb_lap          : std_ulogic_vector(11 downto 0) := X"407"; -- Lap Time & Lap No.
    constant c_data_len         : std_ulogic_vector(3 downto 0)  := X"8";
    variable arb_field          : std_ulogic_vector(10 downto 0);
    variable ctrl_field         : std_ulogic_vector(2 downto 0);
    variable dlen_field         : std_ulogic_vector(3 downto 0);
    variable data_array         : can_data_buf_type;
    variable crc_field          : std_ulogic_vector(14 downto 0);
  begin

    crc_fail <= '0';

    wait until falling_edge(can_rxd_i);
    wait for baud_period / 2;
    stuff_reg <= "11110";
    calc_crc <= "000000000000000";
    wait for baud_period;

    arb_field(10) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(9) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(8) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    arb_field(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    ctrl_field(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    ctrl_field(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    ctrl_field(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    dlen_field(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    dlen_field(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    dlen_field(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    dlen_field(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(0)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(0)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(1)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(1)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(2)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(2)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(3)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(3)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(4)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(4)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(5)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(5)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(6)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(6)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    data_array(7)(7) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(6) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(5) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(4) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(3) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(2) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(1) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);
    data_array(7)(0) := can_rxd_i;
    can_crc_calc(calc_crc, can_rxd_i);
    can_wait_bit(can_rxd_i, stuff_reg);

    crc_field(14) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(13) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(12) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(11) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(10) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(9) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(8) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(7) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(6) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(5) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(4) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(3) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(2) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(1) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);
    crc_field(0) := can_rxd_i;
    can_wait_bit(can_rxd_i, stuff_reg);

    wait for baud_period;
    wait for baud_period;
    wait for baud_period;
    wait for baud_period;
    wait for baud_period;

    rx_arb_field   <= arb_field;
    rx_ctrl_field  <= ctrl_field;
    rx_dlen_field  <= dlen_field;
    rx_fifo        <= data_array;
    calc_crc_field <= calc_crc;
    capt_crc_field <= crc_field;

    if(calc_crc = crc_field) then
      crc_fail <= '0';

      if(arb_field = c_arb_revs(10 downto 0)) then  -- 0x401, Revs, Velocity & Gear
        revs_i      <= to_integer(unsigned(data_array(1)) & unsigned(data_array(0)));
        car_speed_i <= to_integer(unsigned(data_array(3)) & unsigned(data_array(2)));

        if(data_array(6) = X"08") then
          uart_gear_i <= 9;
        elsif(data_array(6) = X"07") then
          uart_gear_i <= 8;
        elsif(data_array(6) = X"06") then
          uart_gear_i <= 7;
        elsif(data_array(6) = X"05") then
          uart_gear_i <= 6;
        elsif(data_array(6) = X"04") then
          uart_gear_i <= 5;
        elsif(data_array(6) = X"03") then
          uart_gear_i <= 4;
        elsif(data_array(6) = X"02") then
          uart_gear_i <= 3;
        elsif(data_array(6) = X"01") then
          uart_gear_i <= 2;
        else
          uart_gear_i <= 0;
        end if;
      end if;

      if(arb_field = c_arb_temp(10 downto 0)) then  -- 0x402, Water Temp & Oil Pressure
        water_temp_i   <= to_integer(unsigned(data_array(0)));
        oil_pressure_i <= to_integer(unsigned(data_array(2)));
      end if;

      if(arb_field = c_arb_shift_lights(10 downto 0)) then  -- 0x405, Shift Lights
        shift_lights_i <= to_integer(unsigned(data_array(6)));
      end if;

      if(arb_field = c_arb_revs_cfg(10 downto 0)) then  -- 0x406, LCD Rev Scale
        revs_cfg_i <= to_integer(unsigned(data_array(1)));
      end if;

      if(arb_field = c_arb_lap(10 downto 0)) then  -- 0x407, Lap Time & Lap No.
        if(data_array(7) = X"80") then
          best_lap_time_i <= to_integer(unsigned(data_array(2)) & unsigned(data_array(1)) & unsigned(data_array(0)));
        elsif(data_array(7) = X"00") then
          lap_time_i <= to_integer(unsigned(data_array(2)) & unsigned(data_array(1)) & unsigned(data_array(0)));
        end if;

        lap_i <= to_integer(unsigned(data_array(4)));
      end if;

    else
      crc_fail <= '1';
    end if;

  end process can_proc;

end behavioral;

