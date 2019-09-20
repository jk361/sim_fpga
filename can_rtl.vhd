
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.can_crc_pkg.all;

entity can_rtl is
  port(
    clk            : in  std_ulogic;
    reset          : in  std_ulogic;
    can_rxd        : in  std_ulogic;
    can_txd        : out std_ulogic;
    can_stb        : out std_ulogic;
    shift_lights   : in  std_ulogic_vector(7 downto 0);
    shift_rdy      : in  std_ulogic;
    uart_gear      : in  std_ulogic_vector(7 downto 0);
    gear_rdy       : in  std_ulogic;
    revs           : in  integer;
    revs_rdy       : in  std_ulogic;
    revs_cfg       : in  integer;
    revs_cfg_rdy   : in  std_ulogic;
    car_speed      : in  integer;
    oil_pressure   : in  integer;
    oil_p_rdy      : in  std_ulogic;
    water_temp     : in  integer;
    water_t_rdy    : in  std_ulogic;
    lap            : in  integer;
    lap_time       : in  integer;
    lap_time_rdy   : in  std_ulogic;
    best_lap_time  : in  integer;
    best_lap_rdy   : in  std_ulogic
    );
end can_rtl;

architecture behavioral of can_rtl is

  signal c_initial_wait : integer := 1999999;

  type tx_state_type is (idle, start,
                         a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0,
                         rr, ide, res, dl3, dl2, dl1, dl0,
                         d0_b7, d0_b6, d0_b5, d0_b4, d0_b3, d0_b2, d0_b1, d0_b0,
                         d1_b7, d1_b6, d1_b5, d1_b4, d1_b3, d1_b2, d1_b1, d1_b0,
                         d2_b7, d2_b6, d2_b5, d2_b4, d2_b3, d2_b2, d2_b1, d2_b0,
                         d3_b7, d3_b6, d3_b5, d3_b4, d3_b3, d3_b2, d3_b1, d3_b0,
                         d4_b7, d4_b6, d4_b5, d4_b4, d4_b3, d4_b2, d4_b1, d4_b0,
                         d5_b7, d5_b6, d5_b5, d5_b4, d5_b3, d5_b2, d5_b1, d5_b0,
                         d6_b7, d6_b6, d6_b5, d6_b4, d6_b3, d6_b2, d6_b1, d6_b0,
                         d7_b7, d7_b6, d7_b5, d7_b4, d7_b3, d7_b2, d7_b1, d7_b0,
                         crc14, crc13, crc12, crc11, crc10, crc9, crc8, crc7, crc6, crc5, crc4, crc3, crc2, crc1, crc0,
                         crc_del, ack_slot, ack_del,
                         eof6, eof5, eof4, eof3, eof2, eof1, eof0,
                         ifs2, ifs1, ifs0);
  signal tx_state : tx_state_type;

  type can_data_buf_type is array (0 to 7) of std_ulogic_vector(7 downto 0);
  signal can_data_buf       : can_data_buf_type;
  constant can_startup_msg0 : can_data_buf_type := (X"02", X"0D", X"00", X"00", X"00", X"00", X"00", X"00");
  constant can_startup_msg1 : can_data_buf_type := (X"00", X"22", X"00", X"00", X"00", X"01", X"00", X"00");
  constant can_startup_msg2 : can_data_buf_type := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  constant can_idle_msg0    : can_data_buf_type := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  constant can_idle_msg1    : can_data_buf_type := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  constant can_idle_msg2    : can_data_buf_type := (X"02", X"0D", X"00", X"00", X"00", X"00", X"00", X"00");
  constant can_idle_msg3    : can_data_buf_type := (X"00", X"00", X"00", X"00", X"0F", X"00", X"00", X"00");
  signal   can_idle_msg4    : can_data_buf_type := (X"00", X"22", X"00", X"00", X"00", X"01", X"00", X"00");

  signal baud_count : integer;
  signal baud_clk   : std_ulogic;

  signal initial_cfg     : std_ulogic := '1';
  signal initial_cfg_msg : integer := 0;
  signal initial_wait    : integer := 0;
  signal idle_cfg_msg    : integer := 0;
  signal can_txd_i       : std_ulogic;
  signal can_stuff_flag  : std_ulogic;
  signal can_stuff_reg   : std_ulogic_vector(3 downto 0);
  signal can_crc_reg     : std_ulogic_vector(14 downto 0);

  signal shift_lights_i  : std_ulogic_vector(7 downto 0);
  signal shift_rdy_i     : std_ulogic;
  signal uart_gear_i     : std_ulogic_vector(7 downto 0);
  signal gear_rdy_i      : std_ulogic;
  signal revs_i          : std_ulogic_vector(15 downto 0);
  signal revs_rdy_i      : std_ulogic;
  signal revs_cfg_i      : std_ulogic_vector(7 downto 0);
  signal revs_cfg_rdy_i  : std_ulogic;
  signal car_speed_i     : std_ulogic_vector(15 downto 0);
  signal oil_pressure_i  : integer;
  signal oil_p_rdy_i     : std_ulogic;
  signal water_temp_i    : integer;
  signal water_t_rdy_i   : std_ulogic;
  signal lap_i           : std_ulogic_vector(7 downto 0);
  signal lap_time_i      : std_ulogic_vector(23 downto 0);
  signal lap_time_rdy_i  : std_ulogic;
  signal best_lap_time_i : std_ulogic_vector(23 downto 0);
  signal best_lap_rdy_i  : std_ulogic;

  signal can_arb_field   : std_ulogic_vector(10 downto 0);
  signal can_idle        : integer;

begin

  can_txd <= can_txd_i;

  can_tx_fsm: process(clk)
    constant c_arb_revs         : std_ulogic_vector(11 downto 0) := X"401"; -- Revs, Velocity & Gear
    constant c_arb_temp         : std_ulogic_vector(11 downto 0) := X"402"; -- Water Temp & Oil Pressure
    constant c_arb_temp_cfg     : std_ulogic_vector(11 downto 0) := X"404"; -- Pressure / Temp Config.
    constant c_arb_shift_lights : std_ulogic_vector(11 downto 0) := X"405"; -- Shift Lights
    constant c_arb_revs_cfg     : std_ulogic_vector(11 downto 0) := X"406"; -- LCD Rev Scale
    constant c_arb_lap          : std_ulogic_vector(11 downto 0) := X"407"; -- Lap Time & Lap No.
    constant c_data_len         : std_ulogic_vector(3 downto 0)  := X"8";
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        can_txd_i       <= '1';
        can_stb         <= '1';
        can_stuff_flag  <= '0';
        can_stuff_reg   <= (others => '0');
        can_crc_reg     <= (others => '0');
        tx_state        <= idle;
        initial_cfg     <= '1';
        initial_cfg_msg <= 0;
        initial_wait    <= 0;
        idle_cfg_msg    <= 0;
        can_arb_field   <= (others => '0');
        can_data_buf    <= (others => (others => '0'));
        shift_rdy_i     <= '0';
        gear_rdy_i      <= '0';
        revs_rdy_i      <= '0';
        revs_cfg_rdy_i  <= '0';
        oil_p_rdy_i     <= '0';
        water_t_rdy_i   <= '0';
        lap_time_rdy_i  <= '0';
        best_lap_rdy_i  <= '0';
        shift_lights_i  <= X"00";
        uart_gear_i     <= X"00";
        revs_i          <= (others => '0');
        revs_cfg_i      <= X"00";
        car_speed_i     <= (others => '0');
        oil_pressure_i  <= 0;
        water_temp_i    <= 0;
        lap_i           <= X"00";
        lap_time_i      <= X"000000";
        best_lap_time_i <= X"000000";
        can_idle        <= 0;
      else

        can_stb <= '0';

        if(shift_rdy = '1') then
          shift_rdy_i    <= '1';
          shift_lights_i <= shift_lights;
        elsif(gear_rdy = '1') then
          gear_rdy_i  <= '1';
          uart_gear_i <= uart_gear;
        elsif(revs_rdy = '1') then
          revs_rdy_i  <= '1';
          revs_i      <= std_ulogic_vector(to_unsigned(revs, 16));
          car_speed_i <= std_ulogic_vector(to_unsigned(car_speed, 16));
        elsif(revs_cfg_rdy = '1') then
          revs_cfg_rdy_i   <= '1';
          revs_cfg_i       <= std_ulogic_vector(to_unsigned(revs_cfg, 8));
          can_idle_msg4(1) <= std_ulogic_vector(to_unsigned(revs_cfg, 8));
        elsif(oil_p_rdy = '1') then
          oil_p_rdy_i    <= '1';
          oil_pressure_i <= oil_pressure;
        elsif(water_t_rdy = '1') then
          water_t_rdy_i <= '1';
          water_temp_i  <= water_temp;
        elsif(lap_time_rdy = '1') then
          lap_time_rdy_i <= '1';
          lap_time_i     <= std_ulogic_vector(to_unsigned(lap_time, 24));
          lap_i          <= std_ulogic_vector(to_unsigned(lap, 8));
        elsif(best_lap_rdy = '1') then
          best_lap_rdy_i  <= '1';
          best_lap_time_i <= std_ulogic_vector(to_unsigned(best_lap_time, 24));
          lap_i           <= std_ulogic_vector(to_unsigned(lap, 8));
        end if;

        if(baud_clk = '1') then

          can_stuff_reg(3) <= can_stuff_reg(2);
          can_stuff_reg(2) <= can_stuff_reg(1);
          can_stuff_reg(1) <= can_stuff_reg(0);
          can_stuff_reg(0) <= can_txd_i;

          if((can_stuff_flag = '1') and ((can_stuff_reg(3 downto 0) & can_txd_i) = "00000")) then
            can_txd_i <= '1';
          elsif((can_stuff_flag = '1') and ((can_stuff_reg(3 downto 0) & can_txd_i) = "11111")) then
            can_txd_i <= '0';
          else

            case tx_state is

              when idle =>

                if(initial_cfg = '1') then
                  if(initial_wait = c_initial_wait) then
                    if(initial_cfg_msg = 0) then
                      can_arb_field <= c_arb_temp_cfg(10 downto 0);
                      can_data_buf  <= can_startup_msg0;
                    elsif(initial_cfg_msg = 1) then
                      can_arb_field <= c_arb_revs_cfg(10 downto 0);
                      can_data_buf  <= can_startup_msg1;
                    elsif(initial_cfg_msg = 2) then
                      can_arb_field <= c_arb_temp(10 downto 0);
                      can_data_buf  <= can_startup_msg2;
                      initial_cfg   <= '0';
                    end if;

                    initial_cfg_msg <= initial_cfg_msg + 1;
                    tx_state        <= start;
                  else
                    initial_wait <= initial_wait + 1;
                  end if;

                else
                  if(shift_rdy_i = '1') then
                    can_arb_field   <= c_arb_shift_lights(10 downto 0);
                    can_data_buf(0) <= X"00";
                    can_data_buf(1) <= X"00";
                    can_data_buf(2) <= X"00";
                    can_data_buf(3) <= X"00";
                    can_data_buf(4) <= X"0F";
                    can_data_buf(5) <= X"1F";
                    can_data_buf(6) <= shift_lights_i;
                    can_data_buf(7) <= X"00";
                    can_idle        <= 0;
                    shift_rdy_i     <= '0';
                    tx_state        <= start;
                  elsif((gear_rdy_i = '1') or (revs_rdy_i = '1')) then
                    can_arb_field   <= c_arb_revs(10 downto 0);
                    can_data_buf(0) <= revs_i(7 downto 0);
                    can_data_buf(1) <= revs_i(15 downto 8);
                    can_data_buf(2) <= car_speed_i(7 downto 0);
                    can_data_buf(3) <= car_speed_i(15 downto 8);
                    can_data_buf(4) <= X"0F";
                    can_data_buf(5) <= X"1F";
                    can_data_buf(6) <= uart_gear_i;
                    can_data_buf(7) <= X"00";
                    can_idle        <= 0;
                    gear_rdy_i      <= '0';
                    revs_rdy_i      <= '0';
                    tx_state        <= start;
                  elsif(revs_cfg_rdy_i = '1') then
                    can_arb_field   <= c_arb_revs_cfg(10 downto 0);
                    can_data_buf(0) <= X"00";
                    can_data_buf(1) <= revs_cfg_i;
                    can_data_buf(2) <= X"00";
                    can_data_buf(3) <= X"00";
                    can_data_buf(4) <= X"00";
                    can_data_buf(5) <= X"01";
                    can_data_buf(6) <= X"00";
                    can_data_buf(7) <= X"00";
                    can_idle        <= 0;
                    revs_cfg_rdy_i  <= '0';
                    tx_state        <= start;
                  elsif((oil_p_rdy_i = '1') or (water_t_rdy_i = '1')) then
                    can_arb_field   <= c_arb_temp(10 downto 0);
                    can_data_buf(0) <= std_ulogic_vector(to_unsigned(water_temp_i, 8));
                    can_data_buf(1) <= X"00";
                    can_data_buf(2) <= std_ulogic_vector(to_unsigned(oil_pressure_i, 8));
                    can_data_buf(3) <= X"00";
                    can_data_buf(4) <= X"00";
                    can_data_buf(5) <= X"00";
                    can_data_buf(6) <= X"00";
                    can_data_buf(7) <= X"00";
                    can_idle        <= 0;
                    oil_p_rdy_i     <= '0';
                    water_t_rdy_i   <= '0';
                    tx_state        <= start;
                  elsif(lap_time_rdy_i = '1') then
                    can_arb_field   <= c_arb_lap(10 downto 0);
                    can_data_buf(0) <= lap_time_i(7 downto 0);
                    can_data_buf(1) <= lap_time_i(15 downto 8);
                    can_data_buf(2) <= lap_time_i(23 downto 16);
                    can_data_buf(3) <= X"00";
                    can_data_buf(4) <= lap_i;
                    can_data_buf(5) <= X"00";
                    can_data_buf(6) <= X"00";
                    can_data_buf(7) <= X"00";
                    can_idle        <= 0;
                    lap_time_rdy_i  <= '0';
                    tx_state        <= start;
                  elsif(best_lap_rdy_i = '1') then
                    can_arb_field   <= c_arb_lap(10 downto 0);
                    can_data_buf(0) <= best_lap_time_i(7 downto 0);
                    can_data_buf(1) <= best_lap_time_i(15 downto 8);
                    can_data_buf(2) <= best_lap_time_i(23 downto 16);
                    can_data_buf(3) <= X"00";
                    can_data_buf(4) <= lap_i;
                    can_data_buf(5) <= X"00";
                    can_data_buf(6) <= X"00";
                    can_data_buf(7) <= X"80";
                    can_idle        <= 0;
                    best_lap_rdy_i  <= '0';
                    tx_state        <= start;
                  else

                    if(initial_cfg = '0') then
                      if(can_idle > 1999999) then
                        idle_cfg_msg <= idle_cfg_msg + 1;
                        tx_state     <= start;

                        if(idle_cfg_msg = 0) then
                          can_arb_field <= c_arb_revs(10 downto 0);
                          can_data_buf  <= can_idle_msg0;
                        elsif(idle_cfg_msg = 1) then
                          can_arb_field <= c_arb_temp(10 downto 0);
                          can_data_buf  <= can_idle_msg1;
                        elsif(idle_cfg_msg = 2) then
                          can_arb_field <= c_arb_temp_cfg(10 downto 0);
                          can_data_buf  <= can_idle_msg2;
                        elsif(idle_cfg_msg = 3) then
                          can_arb_field <= c_arb_shift_lights(10 downto 0);
                          can_data_buf  <= can_idle_msg3;
                        elsif(idle_cfg_msg = 4) then
                          can_arb_field <= c_arb_revs_cfg(10 downto 0);
                          can_data_buf  <= can_idle_msg4;
                          idle_cfg_msg  <= 0;
                          can_idle      <= 0;
                        end if;

                      else
                        can_idle <= can_idle + 1;
                      end if;
                    end if;
                  end if;
                end if;

              when start =>
                can_txd_i      <= '0';
                can_stuff_flag <= '1';
                can_crc_reg    <= (others => '0');
                tx_state       <= a10;

              when a10 =>
                can_crc_calc(can_crc_reg, can_arb_field(10));
                can_txd_i   <= can_arb_field(10);
                tx_state    <= a9;

              when a9 =>
                can_crc_calc(can_crc_reg, can_arb_field(9));
                can_txd_i   <= can_arb_field(9);
                tx_state    <= a8;

              when a8 =>
                can_crc_calc(can_crc_reg, can_arb_field(8));
                can_txd_i   <= can_arb_field(8);
                tx_state    <= a7;

              when a7 =>
                can_crc_calc(can_crc_reg, can_arb_field(7));
                can_txd_i <= can_arb_field(7);
                tx_state  <= a6;

              when a6 =>
                can_crc_calc(can_crc_reg, can_arb_field(6));
                can_txd_i <= can_arb_field(6);
                tx_state  <= a5;

              when a5 =>
                can_crc_calc(can_crc_reg, can_arb_field(5));
                can_txd_i <= can_arb_field(5);
                tx_state  <= a4;

              when a4 =>
                can_crc_calc(can_crc_reg, can_arb_field(4));
                can_txd_i <= can_arb_field(4);
                tx_state  <= a3;

              when a3 =>
                can_crc_calc(can_crc_reg, can_arb_field(3));
                can_txd_i <= can_arb_field(3);
                tx_state  <= a2;

              when a2 =>
                can_crc_calc(can_crc_reg, can_arb_field(2));
                can_txd_i <= can_arb_field(2);
                tx_state  <= a1;

              when a1 =>
                can_crc_calc(can_crc_reg, can_arb_field(1));
                can_txd_i <= can_arb_field(1);
                tx_state  <= a0;

              when a0 =>
                can_crc_calc(can_crc_reg, can_arb_field(0));
                can_txd_i <= can_arb_field(0);
                tx_state  <= rr;

              when rr =>
                can_crc_calc(can_crc_reg, '0');
                can_txd_i <= '0';
                tx_state  <= ide;

              when ide =>
                can_crc_calc(can_crc_reg, '0');
                can_txd_i <= '0';
                tx_state  <= res;

              when res =>
                can_crc_calc(can_crc_reg, '0');
                can_txd_i <= '0';
                tx_state  <= dl3;

              when dl3 =>
                can_crc_calc(can_crc_reg, c_data_len(3));
                can_txd_i <= c_data_len(3);
                tx_state  <= dl2;

              when dl2 =>
                can_crc_calc(can_crc_reg, c_data_len(2));
                can_txd_i <= c_data_len(2);
                tx_state  <= dl1;

              when dl1 =>
                can_crc_calc(can_crc_reg, c_data_len(1));
                can_txd_i <= c_data_len(1);
                tx_state  <= dl0;

              when dl0 =>
                can_crc_calc(can_crc_reg, c_data_len(0));
                can_txd_i <= c_data_len(0);
                tx_state  <= d0_b7;

              when d0_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(7));
                can_txd_i <= can_data_buf(0)(7);
                tx_state  <= d0_b6;

              when d0_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(6));
                can_txd_i <= can_data_buf(0)(6);
                tx_state  <= d0_b5;

              when d0_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(5));
                can_txd_i <= can_data_buf(0)(5);
                tx_state  <= d0_b4;

              when d0_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(4));
                can_txd_i <= can_data_buf(0)(4);
                tx_state  <= d0_b3;

              when d0_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(3));
                can_txd_i <= can_data_buf(0)(3);
                tx_state  <= d0_b2;

              when d0_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(2));
                can_txd_i <= can_data_buf(0)(2);
                tx_state  <= d0_b1;

              when d0_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(1));
                can_txd_i <= can_data_buf(0)(1);
                tx_state  <= d0_b0;

              when d0_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(0)(0));
                can_txd_i <= can_data_buf(0)(0);
                tx_state  <= d1_b7;

              when d1_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(7));
                can_txd_i <= can_data_buf(1)(7);
                tx_state  <= d1_b6;

              when d1_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(6));
                can_txd_i <= can_data_buf(1)(6);
                tx_state  <= d1_b5;

              when d1_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(5));
                can_txd_i <= can_data_buf(1)(5);
                tx_state  <= d1_b4;

              when d1_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(4));
                can_txd_i <= can_data_buf(1)(4);
                tx_state  <= d1_b3;

              when d1_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(3));
                can_txd_i <= can_data_buf(1)(3);
                tx_state  <= d1_b2;

              when d1_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(2));
                can_txd_i <= can_data_buf(1)(2);
                tx_state  <= d1_b1;

              when d1_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(1));
                can_txd_i <= can_data_buf(1)(1);
                tx_state  <= d1_b0;

              when d1_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(1)(0));
                can_txd_i <= can_data_buf(1)(0);
                tx_state  <= d2_b7;

              when d2_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(7));
                can_txd_i <= can_data_buf(2)(7);
                tx_state  <= d2_b6;

              when d2_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(6));
                can_txd_i <= can_data_buf(2)(6);
                tx_state  <= d2_b5;

              when d2_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(5));
                can_txd_i <= can_data_buf(2)(5);
                tx_state  <= d2_b4;

              when d2_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(4));
                can_txd_i <= can_data_buf(2)(4);
                tx_state  <= d2_b3;

              when d2_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(3));
                can_txd_i <= can_data_buf(2)(3);
                tx_state  <= d2_b2;

              when d2_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(2));
                can_txd_i <= can_data_buf(2)(2);
                tx_state  <= d2_b1;

              when d2_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(1));
                can_txd_i <= can_data_buf(2)(1);
                tx_state  <= d2_b0;

              when d2_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(2)(0));
                can_txd_i <= can_data_buf(2)(0);
                tx_state  <= d3_b7;

              when d3_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(7));
                can_txd_i <= can_data_buf(3)(7);
                tx_state  <= d3_b6;

              when d3_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(6));
                can_txd_i <= can_data_buf(3)(6);
                tx_state  <= d3_b5;

              when d3_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(5));
                can_txd_i <= can_data_buf(3)(5);
                tx_state  <= d3_b4;

              when d3_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(4));
                can_txd_i <= can_data_buf(3)(4);
                tx_state  <= d3_b3;

              when d3_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(3));
                can_txd_i <= can_data_buf(3)(3);
                tx_state  <= d3_b2;

              when d3_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(2));
                can_txd_i <= can_data_buf(3)(2);
                tx_state  <= d3_b1;

              when d3_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(1));
                can_txd_i <= can_data_buf(3)(1);
                tx_state  <= d3_b0;

              when d3_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(3)(0));
                can_txd_i <= can_data_buf(3)(0);
                tx_state  <= d4_b7;

              when d4_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(7));
                can_txd_i <= can_data_buf(4)(7);
                tx_state  <= d4_b6;

              when d4_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(6));
                can_txd_i <= can_data_buf(4)(6);
                tx_state  <= d4_b5;

              when d4_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(5));
                can_txd_i <= can_data_buf(4)(5);
                tx_state  <= d4_b4;

              when d4_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(4));
                can_txd_i <= can_data_buf(4)(4);
                tx_state  <= d4_b3;

              when d4_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(3));
                can_txd_i <= can_data_buf(4)(3);
                tx_state  <= d4_b2;

              when d4_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(2));
                can_txd_i <= can_data_buf(4)(2);
                tx_state  <= d4_b1;

              when d4_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(1));
                can_txd_i <= can_data_buf(4)(1);
                tx_state  <= d4_b0;

              when d4_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(4)(0));
                can_txd_i <= can_data_buf(4)(0);
                tx_state  <= d5_b7;

              when d5_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(7));
                can_txd_i <= can_data_buf(5)(7);
                tx_state  <= d5_b6;

              when d5_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(6));
                can_txd_i <= can_data_buf(5)(6);
                tx_state  <= d5_b5;

              when d5_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(5));
                can_txd_i <= can_data_buf(5)(5);
                tx_state  <= d5_b4;

              when d5_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(4));
                can_txd_i <= can_data_buf(5)(4);
                tx_state  <= d5_b3;

              when d5_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(3));
                can_txd_i <= can_data_buf(5)(3);
                tx_state  <= d5_b2;

              when d5_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(2));
                can_txd_i <= can_data_buf(5)(2);
                tx_state  <= d5_b1;

              when d5_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(1));
                can_txd_i <= can_data_buf(5)(1);
                tx_state  <= d5_b0;

              when d5_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(5)(0));
                can_txd_i <= can_data_buf(5)(0);
                tx_state  <= d6_b7;

              when d6_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(7));
                can_txd_i <= can_data_buf(6)(7);
                tx_state  <= d6_b6;

              when d6_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(6));
                can_txd_i <= can_data_buf(6)(6);
                tx_state  <= d6_b5;

              when d6_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(5));
                can_txd_i <= can_data_buf(6)(5);
                tx_state  <= d6_b4;

              when d6_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(4));
                can_txd_i <= can_data_buf(6)(4);
                tx_state  <= d6_b3;

              when d6_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(3));
                can_txd_i <= can_data_buf(6)(3);
                tx_state  <= d6_b2;

              when d6_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(2));
                can_txd_i <= can_data_buf(6)(2);
                tx_state  <= d6_b1;

              when d6_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(1));
                can_txd_i <= can_data_buf(6)(1);
                tx_state  <= d6_b0;

              when d6_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(6)(0));
                can_txd_i <= can_data_buf(6)(0);
                tx_state  <= d7_b7;

              when d7_b7 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(7));
                can_txd_i <= can_data_buf(7)(7);
                tx_state  <= d7_b6;

              when d7_b6 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(6));
                can_txd_i <= can_data_buf(7)(6);
                tx_state  <= d7_b5;

              when d7_b5 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(5));
                can_txd_i <= can_data_buf(7)(5);
                tx_state  <= d7_b4;

              when d7_b4 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(4));
                can_txd_i <= can_data_buf(7)(4);
                tx_state  <= d7_b3;

              when d7_b3 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(3));
                can_txd_i <= can_data_buf(7)(3);
                tx_state  <= d7_b2;

              when d7_b2 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(2));
                can_txd_i <= can_data_buf(7)(2);
                tx_state  <= d7_b1;

              when d7_b1 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(1));
                can_txd_i <= can_data_buf(7)(1);
                tx_state  <= d7_b0;

              when d7_b0 =>
                can_crc_calc(can_crc_reg, can_data_buf(7)(0));
                can_txd_i      <= can_data_buf(7)(0);
                tx_state       <= crc14;

              when crc14 =>
                can_txd_i <= can_crc_reg(14);
                tx_state  <= crc13;

              when crc13 =>
                can_txd_i <= can_crc_reg(13);
                tx_state  <= crc12;

              when crc12 =>
                can_txd_i <= can_crc_reg(12);
                tx_state  <= crc11;

              when crc11 =>
                can_txd_i <= can_crc_reg(11);
                tx_state  <= crc10;

              when crc10 =>
                can_txd_i <= can_crc_reg(10);
                tx_state  <= crc9;

              when crc9 =>
                can_txd_i <= can_crc_reg(9);
                tx_state  <= crc8;

              when crc8 =>
                can_txd_i <= can_crc_reg(8);
                tx_state  <= crc7;

              when crc7 =>
                can_txd_i <= can_crc_reg(7);
                tx_state  <= crc6;

              when crc6 =>
                can_txd_i <= can_crc_reg(6);
                tx_state  <= crc5;

              when crc5 =>
                can_txd_i <= can_crc_reg(5);
                tx_state  <= crc4;

              when crc4 =>
                can_txd_i <= can_crc_reg(4);
                tx_state  <= crc3;

              when crc3 =>
                can_txd_i <= can_crc_reg(3);
                tx_state  <= crc2;

              when crc2 =>
                can_txd_i <= can_crc_reg(2);
                tx_state  <= crc1;

              when crc1 =>
                can_txd_i <= can_crc_reg(1);
                tx_state  <= crc0;

              when crc0 =>
                can_txd_i      <= can_crc_reg(0);
                can_stuff_flag <= '0';
                tx_state       <= crc_del;

              when crc_del =>
                can_txd_i <= '1';
                tx_state  <= ack_slot;

              when ack_slot =>
                can_txd_i <= '0';
                tx_state  <= ack_del;

              when ack_del =>
                can_txd_i <= '1';
                tx_state  <= eof6;

              when eof6 =>
                can_txd_i <= '1';
                tx_state  <= eof5;

              when eof5 =>
                can_txd_i <= '1';
                tx_state  <= eof4;

              when eof4 =>
                can_txd_i <= '1';
                tx_state  <= eof3;

              when eof3 =>
                can_txd_i <= '1';
                tx_state  <= eof2;

              when eof2 =>
                can_txd_i <= '1';
                tx_state  <= eof1;

              when eof1 =>
                can_txd_i <= '1';
                tx_state  <= eof0;

              when eof0 =>
                can_txd_i <= '1';
                tx_state  <= ifs2;

              when ifs2 =>
                can_txd_i <= '1';
                tx_state  <= ifs1;

              when ifs1 =>
                can_txd_i <= '1';
                tx_state  <= ifs0;

              when ifs0 =>
                can_txd_i <= '1';
                tx_state  <= idle;

              when others =>
                tx_state <= idle;

            end case;

          end if;
        end if;
      end if;
    end if;
  end process can_tx_fsm;

  baud_gen: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        baud_count <= 0;
        baud_clk   <= '0';
      else
        if(baud_count = 47) then
          baud_count <= 0;
          baud_clk   <= '1';
        else
          baud_count <= baud_count + 1;
          baud_clk   <= '0';
        end if;
      end if;
    end if;
  end process baud_gen;


end behavioral;

