
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_intfc_rtl is
  port(
    clk           : in  std_ulogic;
    reset         : in  std_ulogic;
    adc_sck       : out std_ulogic;
    adc_sdi       : in  std_ulogic;
    adc_sdo       : out std_ulogic;
    adc_cs        : out std_ulogic;
    steer_angle   : out integer;
    motor_current : out integer;
    sens_gear     : out integer;
    test_op       : out integer;
    uart_txd      : out std_ulogic
    );
end adc_intfc_rtl;

architecture behavioral of adc_intfc_rtl is

  constant cha_cfg : std_ulogic_vector(3 downto 0) := X"8";
  constant chb_cfg : std_ulogic_vector(3 downto 0) := X"9";
  constant chc_cfg : std_ulogic_vector(3 downto 0) := X"A";
  constant chd_cfg : std_ulogic_vector(3 downto 0) := X"B";
  signal ch_cfg    : std_ulogic_vector(3 downto 0);

  type rx_state_type is (idle, start0, start1, start2, start3, start4,
                         wait0, wait1,
                         d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11,
                         stop0, stop1);

  signal rx_state : rx_state_type;

  signal ch_buf  : std_ulogic_vector(11 downto 0);

  type buf_fifo_type is array (0 to 9) of std_ulogic_vector(11 downto 0);
  signal chb_fifo : buf_fifo_type;

  signal spi_clk       : std_ulogic;
  signal spi_clk_count : integer;
  signal tick          : std_ulogic;
  signal tick_count    : integer;
  signal adc_sck_i     : std_ulogic;

  type steer_fifo_type is array (0 to 9) of integer;
  signal steer_fifo    : steer_fifo_type;

  signal steer_angle_prev : integer;
  signal offset_prev      : integer;

  signal gear_rot      : integer;
  signal gear_lin      : integer;

begin

  adc_sck <= adc_sck_i;

  spi_clk_gen: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        spi_clk       <= '0';
        spi_clk_count <= 0;
      else
        if(spi_clk_count = 23) then
          spi_clk       <= '1';
          spi_clk_count <= 0;
        else
          spi_clk       <= '0';
          spi_clk_count <= spi_clk_count + 1;
        end if;
      end if;
    end if;
  end process spi_clk_gen;

  sample_tick: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        tick       <= '0';
        tick_count <= 0;
      else
        if(tick_count = 9599) then
          tick       <= '1';
          tick_count <= 0;
        else
          tick       <= '0';
          tick_count <= tick_count + 1;
        end if;
      end if;
    end if;
  end process sample_tick;

  adc_i: process(clk)
    constant rot_up        : integer := 1860;
    constant rot_dn        : integer := 1640;
    constant lin_dn        : integer := 200;
    constant lin_up        : integer := 3800;
    variable steer_angle_i : integer := 0;
    variable offset        : integer := 0;
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        adc_sck_i        <= '1';
        adc_sdo          <= '0';
        adc_cs           <= '1';
        steer_angle      <= 0;
        steer_angle_prev <= 0;
        motor_current    <= 0;
        rx_state         <= idle;
        ch_cfg           <= cha_cfg;
        ch_buf           <= (others => '0');
        chb_fifo         <= (others => (others => '0'));
        steer_fifo       <= (others => 0);
        uart_txd         <= '1';
        test_op          <= 0;
        sens_gear        <= 0;
        offset_prev      <= 0;
      elsif (spi_clk = '1') then

        case rx_state is

          when idle =>
            if(tick = '1') then
              rx_state  <= start0;
              adc_cs    <= '0';
              adc_sck_i <= '0';
              adc_sdo   <= '1';
            end if;

          when start0 =>
            if(adc_sck_i = '0') then
              rx_state  <= start1;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_cs    <= '0';
              adc_sdo   <= '1';
            end if;

          when start1 =>
            if(adc_sck_i = '0') then
              rx_state  <= start2;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_sdo   <= ch_cfg(3);
            end if;

          when start2 =>
            if(adc_sck_i = '0') then
              rx_state  <= start3;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_sdo   <= ch_cfg(2);
            end if;

          when start3 =>
            if(adc_sck_i = '0') then
              rx_state  <= start4;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_sdo   <= ch_cfg(1);
            end if;

          when start4 =>
            if(adc_sck_i = '0') then
              rx_state  <= wait0;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_sdo   <= ch_cfg(0);
            end if;

          when wait0 =>
            if(adc_sck_i = '0') then
              rx_state  <= wait1;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
              adc_sdo   <= '0';
            end if;

          when wait1 =>
            if(adc_sck_i = '0') then
              rx_state  <= d11;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d11 =>
            if(adc_sck_i = '0') then
              rx_state   <= d10;
              ch_buf(11) <= adc_sdi;
              adc_sck_i  <= '1';
            else
              adc_sck_i  <= '0';
            end if;

          when d10 =>
            if(adc_sck_i = '0') then
              rx_state   <= d9;
              ch_buf(10) <= adc_sdi;
              adc_sck_i  <= '1';
            else
              adc_sck_i  <= '0';
            end if;

          when d9 =>
            if(adc_sck_i = '0') then
              rx_state  <= d8;
              ch_buf(9) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i  <= '0';
            end if;

          when d8 =>
            if(adc_sck_i = '0') then
              rx_state  <= d7;
              ch_buf(8) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d7 =>
            if(adc_sck_i = '0') then
              rx_state  <= d6;
              ch_buf(7) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d6 =>
            if(adc_sck_i = '0') then
              rx_state  <= d5;
              ch_buf(6) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d5 =>
            if(adc_sck_i = '0') then
              rx_state  <= d4;
              ch_buf(5) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d4 =>
            if(adc_sck_i = '0') then
              rx_state  <= d3;
              ch_buf(4) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d3 =>
            if(adc_sck_i = '0') then
              rx_state  <= d2;
              ch_buf(3) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d2 =>
            if(adc_sck_i = '0') then
              rx_state  <= d1;
              ch_buf(2) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d1 =>
            if(adc_sck_i = '0') then
              rx_state  <= d0;
              ch_buf(1) <= adc_sdi;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';
            end if;

          when d0 =>
            if(adc_sck_i = '0') then
              adc_sck_i <= '1';

              if(ch_cfg = cha_cfg) then
                ch_cfg      <= chb_cfg;
                rx_state    <= stop0;
                gear_lin <= to_integer(unsigned(ch_buf(11 downto 1) & adc_sdi));

              elsif(ch_cfg = chb_cfg) then
                ch_cfg        <= chc_cfg;
                rx_state      <= stop0;
                chb_fifo(9)   <= chb_fifo(8);
                chb_fifo(8)   <= chb_fifo(7);
                chb_fifo(7)   <= chb_fifo(6);
                chb_fifo(6)   <= chb_fifo(5);
                chb_fifo(5)   <= chb_fifo(4);
                chb_fifo(4)   <= chb_fifo(3);
                chb_fifo(3)   <= chb_fifo(2);
                chb_fifo(2)   <= chb_fifo(1);
                chb_fifo(1)   <= chb_fifo(0);
                chb_fifo(0)   <= ch_buf(11 downto 1) & adc_sdi;
                motor_current <= (1250 * (to_integer(unsigned(chb_fifo(8))) + to_integer(unsigned(chb_fifo(7))) + to_integer(unsigned(chb_fifo(6))) + to_integer(unsigned(chb_fifo(5))) + to_integer(unsigned(chb_fifo(4))) +
                                          to_integer(unsigned(chb_fifo(3))) + to_integer(unsigned(chb_fifo(2))) + to_integer(unsigned(chb_fifo(1))) + to_integer(unsigned(chb_fifo(0))) + to_integer(unsigned(ch_buf(11 downto 1) & adc_sdi)))) / 1024;

              elsif(ch_cfg = chc_cfg) then
                ch_cfg        <= chd_cfg;
                rx_state      <= stop0;

                steer_angle_i    := to_integer(unsigned(ch_buf(11 downto 1)) & adc_sdi) - 2048;
                steer_angle_prev <= steer_angle_i;
--              offset           := offset_prev;

                if((steer_angle_i <= 2047) and (steer_angle_i > 1023) and (steer_angle_prev < -1024) and (steer_angle_prev >= -2048)) then
                  if(offset_prev >= 0) then
                    offset := offset - 4096;
                  else
--                  steer_angle_i := -2048;
                  end if;
                elsif((steer_angle_i >= -2048) and (steer_angle_i < -1024) and (steer_angle_prev > 1023) and (steer_angle_prev <= 2047)) then
                  if(offset_prev <= 0) then
                    offset := offset + 4096;
                  else
--                  steer_angle_i := 2048;
                  end if;
                end if;

                offset_prev <= offset;

                steer_fifo(9) <= steer_fifo(8);
                steer_fifo(8) <= steer_fifo(7);
                steer_fifo(7) <= steer_fifo(6);
                steer_fifo(6) <= steer_fifo(5);
                steer_fifo(5) <= steer_fifo(4);
                steer_fifo(4) <= steer_fifo(3);
                steer_fifo(3) <= steer_fifo(2);
                steer_fifo(2) <= steer_fifo(1);
                steer_fifo(1) <= steer_fifo(0);
                steer_fifo(0) <= steer_angle_i + offset;
                steer_angle   <= steer_fifo(7) + steer_fifo(6) + steer_fifo(5) + steer_fifo(4) + steer_fifo(3) + steer_fifo(2) + steer_fifo(1) + steer_fifo(0) + (steer_angle_i + offset);

              elsif(ch_cfg = chd_cfg) then
                rx_state    <= stop1;
                ch_cfg      <= cha_cfg;
                gear_rot <= to_integer(unsigned(ch_buf(11 downto 1) & adc_sdi));

              end if;
            else
              adc_sck_i <= '0';
            end if;

          when stop0 =>
            if(adc_sck_i = '0') then
              rx_state    <= start0;
              adc_sck_i   <= '1';
            else
              adc_sck_i <= '0';
              adc_cs    <= '1';
            end if;

          when stop1 =>
            adc_cs <= '1';

            if(adc_sck_i = '0') then
              rx_state  <= idle;
              adc_sck_i <= '1';
            else
              adc_sck_i <= '0';

              if(gear_rot < rot_dn) then
                if(gear_lin < lin_dn) then
                  sens_gear <= 5;
                elsif(gear_lin > lin_up) then
                  sens_gear <= 6;
                else
                  sens_gear <= 0;
                end if;
              elsif(gear_rot > rot_up) then
                if(gear_lin < lin_dn) then
                  sens_gear <= 1;
                elsif(gear_lin > lin_up) then
                  sens_gear <= 2;
                else
                  sens_gear <= 0;
                end if;
              else
                if(gear_lin < lin_dn) then
                  sens_gear <= 3;
                elsif(gear_lin > lin_up) then
                  sens_gear <= 4;
                else
                  sens_gear <= 0;
                end if;
              end if;
            end if;

          when others =>
            rx_state <= idle;
            adc_cs   <= '1';

        end case;
      end if;
    end if;
  end process adc_i;

end behavioral;
