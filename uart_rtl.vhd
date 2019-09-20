
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rtl is
  port(
    clk            : in  std_ulogic;
    reset          : in  std_ulogic;
    uart_rxd       : in  std_ulogic;
    uart_txd       : out std_ulogic;
    shift_lights   : out std_ulogic_vector(7 downto 0);
    shift_rdy      : out std_ulogic;
    uart_gear      : out std_ulogic_vector(7 downto 0);
    gear_rdy       : out std_ulogic;
    revs           : out integer;
    revs_rdy       : out std_ulogic;
    revs_cfg       : out integer;
    revs_cfg_rdy   : out std_ulogic;
    car_speed      : out integer;
    speed_rdy      : out std_ulogic;
    oil_pressure   : out integer;
    oil_p_rdy      : out std_ulogic;
    water_temp     : out integer;
    water_t_rdy    : out std_ulogic;
    lap            : out integer;
    lap_rdy        : out std_ulogic;
    lap_time       : out integer;
    lap_time_rdy   : out std_ulogic;
    best_lap_time  : out integer;
    best_lap_rdy   : out std_ulogic;
    force_feedback : out integer;
    ff_rdy         : out std_ulogic
    );
end uart_rtl;

architecture behavioral of uart_rtl is

  signal rx_state : integer;

  type rx_fifo_type is array (0 to 9) of std_ulogic_vector(7 downto 0);
  signal rx_fifo : rx_fifo_type;

  signal baud_count : integer;

  signal rx_byte : std_ulogic_vector(7 downto 0);

  signal baud_clk : std_ulogic;
  signal rxd_prev : std_ulogic;

begin

  uart_txd <= '0';

  baud_gen: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        baud_count <= 0;
        baud_clk   <= '0';
      else
        if(baud_count = 5) then
          baud_count <= 0;
          baud_clk   <= '1';
        else
          baud_count <= baud_count + 1;
          baud_clk   <= '0';
        end if;
      end if;
    end if;
  end process baud_gen;

  uart_rx: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        rx_state       <= 0;
        rx_byte        <= X"00";
        rx_fifo        <= (others => (others => '0'));
        shift_lights   <= X"00";
        uart_gear      <= X"FF";
        revs           <= 0;
        revs_cfg       <= 0;
        car_speed      <= 0;
        oil_pressure   <= 0;
        water_temp     <= 0;
        lap            <= 0;
        lap_time       <= 0;
        best_lap_time  <= 0;
        force_feedback <= 0;
        shift_rdy      <= '0';
        gear_rdy       <= '0';
        revs_rdy       <= '0';
        revs_cfg_rdy   <= '0';
        speed_rdy      <= '0';
        oil_p_rdy      <= '0';
        water_t_rdy    <= '0';
        lap_rdy        <= '0';
        lap_time_rdy   <= '0';
        best_lap_rdy   <= '0';
        ff_rdy         <= '0';
      elsif (baud_clk = '1') then
        rxd_prev     <= uart_rxd;
        shift_rdy    <= '0';
        gear_rdy     <= '0';
        revs_rdy     <= '0';
        revs_cfg_rdy <= '0';
        speed_rdy    <= '0';
        oil_p_rdy    <= '0';
        water_t_rdy  <= '0';
        lap_rdy      <= '0';
        lap_time_rdy <= '0';
        best_lap_rdy <= '0';
        ff_rdy       <= '0';

        case rx_state is

          when 0 =>
            if(uart_rxd = '0' and rxd_prev = '1') then
              rx_state <= 1;
            end if;

          when 23 =>
            rx_byte(0) <= uart_rxd;
            rx_state   <= 24;

          when 39 =>
            rx_byte(1) <= uart_rxd;
            rx_state   <= 40;

          when 55 =>
            rx_byte(2) <= uart_rxd;
            rx_state   <= 56;

          when 71 =>
            rx_byte(3) <= uart_rxd;
            rx_state   <= 72;

          when 87 =>
            rx_byte(4) <= uart_rxd;
            rx_state   <= 88;

          when 103 =>
            rx_byte(5) <= uart_rxd;
            rx_state   <= 104;

          when 119 =>
            rx_byte(6) <= uart_rxd;
            rx_state   <= 120;

          when 135 =>
            rx_fifo(9)    <= rx_fifo(8);
            rx_fifo(8)    <= rx_fifo(7);
            rx_fifo(7)    <= rx_fifo(6);
            rx_fifo(6)    <= rx_fifo(5);
            rx_fifo(5)    <= rx_fifo(4);
            rx_fifo(4)    <= rx_fifo(3);
            rx_fifo(3)    <= rx_fifo(2);
            rx_fifo(2)    <= rx_fifo(1);
            rx_fifo(1)    <= rx_fifo(0);
            rx_fifo(0)    <= uart_rxd & rx_byte(6 downto 0);
            rx_state      <= 136;

            if(uart_rxd & rx_byte(6 downto 0) = X"20") then
              rx_fifo(0) <= X"30";
            end if;

          when 136 =>
            -- Shift Lights
            if(rx_fifo(1) = X"4C") then
              shift_rdy <= '1';
              if(rx_fifo(0) = X"35") then
                shift_lights <= X"1F";
              elsif(rx_fifo(0) = X"34") then
                shift_lights <= X"0F";
              elsif(rx_fifo(0) = X"33") then
                shift_lights <= X"07";
              elsif(rx_fifo(0) = X"32") then
                shift_lights <= X"03";
              elsif(rx_fifo(0) = X"31") then
                shift_lights <= X"01";
              else
                shift_lights <= X"00";
              end if;

            -- Gear
            elsif(rx_fifo(1) = X"47") then
              gear_rdy <= '1';
              if(rx_fifo(0) = X"39") then
                uart_gear <= X"08";
              elsif(rx_fifo(0) = X"38") then
                uart_gear <= X"07";
              elsif(rx_fifo(0) = X"37") then
                uart_gear <= X"06";
              elsif(rx_fifo(0) = X"36") then
                uart_gear <= X"05";
              elsif(rx_fifo(0) = X"35") then
                uart_gear <= X"04";
              elsif(rx_fifo(0) = X"34") then
                uart_gear <= X"03";
              elsif(rx_fifo(0) = X"33") then
                uart_gear <= X"02";
              elsif(rx_fifo(0) = X"32") then
                uart_gear <= X"01";
              else
                uart_gear <= X"FF";
              end if;

            -- Revs (Rpm) & Car Speed (Kph)
            elsif(rx_fifo(8) = X"52") then
              if((rx_fifo(7) > X"2F") and (rx_fifo(7) < X"3A") and (rx_fifo(6) > X"2F") and (rx_fifo(6) < X"3A") and (rx_fifo(5) > X"2F") and (rx_fifo(5) < X"3A") and (rx_fifo(4) > X"2F") and (rx_fifo(4) < X"3A") and (rx_fifo(3) > X"2F") and (rx_fifo(3) < X"3A")) then
                revs_rdy <= '1';
                revs     <= ((to_integer(unsigned(rx_fifo(7))) - 48) * 10000) +
                            ((to_integer(unsigned(rx_fifo(6))) - 48) * 1000) +
                            ((to_integer(unsigned(rx_fifo(5))) - 48) * 100) +
                            ((to_integer(unsigned(rx_fifo(4))) - 48) * 10) +
                              to_integer(unsigned(rx_fifo(3)) - 48);
              end if;
              if((rx_fifo(2) > X"2F") and (rx_fifo(2) < X"3A") and (rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then
                speed_rdy <= '1';
                car_speed <= ((to_integer(unsigned(rx_fifo(2))) - 48) * 1000) +
                             ((to_integer(unsigned(rx_fifo(1))) - 48) * 100) +
                             ((to_integer(unsigned(rx_fifo(0))) - 48) * 10);
              end if;

            -- Oil Pressure (Bar * 10)
            elsif(rx_fifo(2) = X"4F") then
              if((rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then
                oil_p_rdy    <= '1';
                oil_pressure <= ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) +
                                 (to_integer(unsigned(rx_fifo(0))) - 48);
              end if;

            -- Water Temperature (Celcius)
            elsif(rx_fifo(2) = X"45") then
              if((rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then
                water_t_rdy <= '1';
                water_temp  <= ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) +
                                (to_integer(unsigned(rx_fifo(0))) - 48);
              end if;

            -- Lap Time and Lap Number
            elsif(rx_fifo(8) = X"54") then
              if((rx_fifo(7) > X"2F") and (rx_fifo(7) < X"3A") and (rx_fifo(6) > X"2F") and (rx_fifo(6) < X"3A") and (rx_fifo(5) > X"2F") and (rx_fifo(5) < X"3A") and (rx_fifo(4) > X"2F") and (rx_fifo(4) < X"3A") and (rx_fifo(3) > X"2F") and (rx_fifo(3) < X"3A")) then
                lap_time_rdy <= '1';
                lap_time     <= ((to_integer(unsigned(rx_fifo(7))) - 48) * 100000) +
                                ((to_integer(unsigned(rx_fifo(6))) - 48) * 10000) +
                                ((to_integer(unsigned(rx_fifo(5))) - 48) * 1000) +
                                ((to_integer(unsigned(rx_fifo(4))) - 48) * 100) +
                                ((to_integer(unsigned(rx_fifo(3))) - 48) * 10);
              end if;
              if((rx_fifo(2) > X"2F") and (rx_fifo(2) < X"3A") and (rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then
                lap_rdy <= '1';
                lap     <= ((to_integer(unsigned(rx_fifo(2))) - 48) * 100) +
                           ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) +
                            (to_integer(unsigned(rx_fifo(0))) - 48);
              end if;

            -- Best Lap Time and Lap Number
            elsif(rx_fifo(8) = X"42") then
              if((rx_fifo(7) > X"2F") and (rx_fifo(7) < X"3A") and (rx_fifo(6) > X"2F") and (rx_fifo(6) < X"3A") and (rx_fifo(5) > X"2F") and (rx_fifo(5) < X"3A") and (rx_fifo(4) > X"2F") and (rx_fifo(4) < X"3A") and (rx_fifo(3) > X"2F") and (rx_fifo(3) < X"3A")) then
                best_lap_rdy   <= '1';
                best_lap_time  <= ((to_integer(unsigned(rx_fifo(7))) - 48) * 100000) +
                                  ((to_integer(unsigned(rx_fifo(6))) - 48) * 10000) +
                                  ((to_integer(unsigned(rx_fifo(5))) - 48) * 1000) +
                                  ((to_integer(unsigned(rx_fifo(4))) - 48) * 100) +
                                  ((to_integer(unsigned(rx_fifo(3))) - 48) * 10);
              end if;
              if((rx_fifo(2) > X"2F") and (rx_fifo(2) < X"3A") and (rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then
                lap_rdy <= '1';
                lap     <= ((to_integer(unsigned(rx_fifo(2))) - 48) * 100) +
                           ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) +
                            (to_integer(unsigned(rx_fifo(0))) - 48);
              end if;

            -- Force Feedback
            elsif(rx_fifo(6) = X"46") then
              if(((rx_fifo(5) > X"20") or (rx_fifo(5) > X"2B") or (rx_fifo(5) < X"2D")) and (rx_fifo(4) > X"2F") and (rx_fifo(4) < X"3A") and (rx_fifo(3) > X"2F") and (rx_fifo(3) < X"3A") and (rx_fifo(2) > X"2F") and (rx_fifo(2) < X"3A") and (rx_fifo(1) > X"2F") and (rx_fifo(1) < X"3A") and (rx_fifo(0) > X"2F") and (rx_fifo(0) < X"3A")) then

                if((rx_fifo(5) = X"20") or (rx_fifo(5) = X"2B")) then
                  ff_rdy         <= '1';
                  force_feedback <= ((to_integer(unsigned(rx_fifo(4))) - 48) * 10000) +
                                    ((to_integer(unsigned(rx_fifo(3))) - 48) * 1000) +
                                    ((to_integer(unsigned(rx_fifo(2))) - 48) * 100) +
                                    ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) +
                                     (to_integer(unsigned(rx_fifo(0))) - 48);
                elsif(rx_fifo(5) = X"2D") then
                  ff_rdy         <= '1';
                  force_feedback <= 0 -
                                    ((to_integer(unsigned(rx_fifo(4))) - 48) * 10000) -
                                    ((to_integer(unsigned(rx_fifo(3))) - 48) * 1000) -
                                    ((to_integer(unsigned(rx_fifo(2))) - 48) * 100) -
                                    ((to_integer(unsigned(rx_fifo(1))) - 48) * 10) -
                                     (to_integer(unsigned(rx_fifo(0))) - 48);
                end if;
              end if;

            -- Dash Rev Scale
            elsif(rx_fifo(1) = X"58") then
              if((rx_fifo(0) > X"2F") and (rx_fifo(0) < X"39")) then
                revs_cfg_rdy <= '1';

                if(rx_fifo(0) = X"30") then
                  revs_cfg <= 2;
                elsif(rx_fifo(0) = X"31") then
                  revs_cfg <= 18;
                elsif(rx_fifo(0) = X"32") then
                  revs_cfg <= 34;
                elsif(rx_fifo(0) = X"33") then
                  revs_cfg <= 50;
                elsif(rx_fifo(0) = X"34") then
                  revs_cfg <= 66;
                elsif(rx_fifo(0) = X"35") then
                  revs_cfg <= 82;
                elsif(rx_fifo(0) = X"36") then
                  revs_cfg <= 98;
                elsif(rx_fifo(0) = X"37") then
                  revs_cfg <= 114;
                elsif(rx_fifo(0) = X"38") then
                  revs_cfg <= 130;
                end if;

              end if;
           end if;

            rx_state <= 0;

          when others =>
            rx_state    <= rx_state + 1;

        end case;

      end if;
    end if;
  end process uart_rx;

end behavioral;
