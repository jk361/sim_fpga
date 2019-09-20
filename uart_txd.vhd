
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debug_uart_comp is
  port(
    clk      : in  std_ulogic;
    reset    : in  std_ulogic;
    uart_txd : out std_ulogic;
    input    : in  integer
    );
end debug_uart_comp;

architecture behavioral of debug_uart_comp is

  signal baud_count : integer;
  signal baud_clk   : std_ulogic;

  signal tx_state   : integer;

  type tx_fifo_type is array (0 to 6) of std_ulogic_vector(7 downto 0);
  signal tx_fifo : tx_fifo_type;

begin

  baud_gen: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        baud_count <= 0;
        baud_clk   <= '0';
      else
        if(baud_count = 95) then
          baud_count <= 0;
          baud_clk   <= '1';
        else
          baud_count <= baud_count + 1;
          baud_clk   <= '0';
        end if;
      end if;
    end if;
  end process baud_gen;

  uart_tx_i: process(clk)
    constant dp      : std_ulogic_vector(7 downto 0) := X"2E";
    variable hex_src : std_ulogic_vector(15 downto 0);
    variable bcd     : std_ulogic_vector(19 downto 0);
    variable loop_i  : integer;
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        uart_txd   <= '1';
        tx_fifo(6) <= X"30";
        tx_fifo(5) <= X"30";
        tx_fifo(4) <= X"30";
        tx_fifo(3) <= X"30";
        tx_fifo(2) <= X"30";
        tx_fifo(1) <= X"30";
        tx_fifo(0) <= X"0D";
        tx_state   <= 0;
        loop_i     := 0;
      elsif (baud_clk = '1') then

        case tx_state is

          when 0 =>

            if(loop_i = 0) then
              if((input <= 65536) and (input >= -65536)) then
                hex_src := std_ulogic_vector(to_unsigned(abs(input), 16));

                if(input < 0) then
                  tx_fifo(6) <= X"2D";
                else
                  tx_fifo(6) <= X"20";
                end if;
              end if;

              bcd := (others => '0');

            end if;

            if to_integer(unsigned(bcd(3 downto 0))) > 4 then
              bcd(3 downto 0) := std_ulogic_vector(to_unsigned(to_integer(unsigned(bcd(3 downto 0))) + 3, 4));
            end if;

            if to_integer(unsigned(bcd(7 downto 4))) > 4 then
              bcd(7 downto 4) := std_ulogic_vector(to_unsigned(to_integer(unsigned(bcd(7 downto 4))) + 3, 4));
            end if;

            if to_integer(unsigned(bcd(11 downto 8))) > 4 then
              bcd(11 downto 8) := std_ulogic_vector(to_unsigned(to_integer(unsigned(bcd(11 downto 8))) + 3, 4));
            end if;

            if to_integer(unsigned(bcd(15 downto 12))) > 4 then
              bcd(15 downto 12) := std_ulogic_vector(to_unsigned(to_integer(unsigned(bcd(15 downto 12))) + 3, 4));
            end if;

            if to_integer(unsigned(bcd(19 downto 16))) > 4 then
              bcd(19 downto 16) := std_ulogic_vector(to_unsigned(to_integer(unsigned(bcd(15 downto 12))) + 3, 4));
            end if;

            bcd     := bcd(18 downto 0) & hex_src(15); -- shift bcd + 1 new entry
            hex_src := hex_src(14 downto 0) & '0';     -- shift src + pad with 0

            if(loop_i = 15) then
              loop_i     := 0;
              tx_fifo(5) <= X"3" & bcd(19 downto 16);
              tx_fifo(4) <= X"3" & bcd(15 downto 12);
              tx_fifo(3) <= X"3" & bcd(11 downto 8);
              tx_fifo(2) <= X"3" & bcd(7 downto 4);
              tx_fifo(1) <= X"3" & bcd(3 downto 0);
              uart_txd   <= '0';
              tx_state   <= 1;
            else
              loop_i     := loop_i + 1;
            end if;

          when 1 =>
            uart_txd <= tx_fifo(6)(0);
            tx_state <= 2;
          when 2 =>
            uart_txd <= tx_fifo(6)(1);
            tx_state <= 3;
          when 3 =>
            uart_txd <= tx_fifo(6)(2);
            tx_state <= 4;
          when 4 =>
            uart_txd <= tx_fifo(6)(3);
            tx_state <= 5;
          when 5 =>
            uart_txd <= tx_fifo(6)(4);
            tx_state <= 6;
          when 6 =>
            uart_txd <= tx_fifo(6)(5);
            tx_state <= 7;
          when 7 =>
            uart_txd <= tx_fifo(6)(6);
            tx_state <= 8;
          when 8 =>
            uart_txd <= tx_fifo(6)(7);
            tx_state <= 9;
          when 9 =>
            uart_txd <= '1';
            tx_state <= 10;

          when 10 =>
            uart_txd <= '0';
            tx_state <= 11;
          when 11 =>
            uart_txd <= tx_fifo(5)(0);
            tx_state <= 12;
          when 12 =>
            uart_txd <= tx_fifo(5)(1);
            tx_state <= 13;
          when 13 =>
            uart_txd <= tx_fifo(5)(2);
            tx_state <= 14;
          when 14 =>
            uart_txd <= tx_fifo(5)(3);
            tx_state <= 15;
          when 15 =>
            uart_txd <= tx_fifo(5)(4);
            tx_state <= 16;
          when 16 =>
            uart_txd <= tx_fifo(5)(5);
            tx_state <= 17;
          when 17 =>
            uart_txd <= tx_fifo(5)(6);
            tx_state <= 18;
          when 18 =>
            uart_txd <= tx_fifo(5)(7);
            tx_state <= 19;
          when 19 =>
            uart_txd <= '1';
            tx_state <= 20;

          when 20 =>
            uart_txd <= '0';
            tx_state <= 21;
          when 21 =>
            uart_txd <= tx_fifo(4)(0);
            tx_state <= 22;
          when 22 =>
            uart_txd <= tx_fifo(4)(1);
            tx_state <= 23;
          when 23 =>
            uart_txd <= tx_fifo(4)(2);
            tx_state <= 24;
          when 24 =>
            uart_txd <= tx_fifo(4)(3);
            tx_state <= 25;
          when 25 =>
            uart_txd <= tx_fifo(4)(4);
            tx_state <= 26;
          when 26 =>
            uart_txd <= tx_fifo(4)(5);
            tx_state <= 27;
          when 27 =>
            uart_txd <= tx_fifo(4)(6);
            tx_state <= 28;
          when 28 =>
            uart_txd <= tx_fifo(4)(7);
            tx_state <= 29;
          when 29 =>
            uart_txd <= '1';
            tx_state <= 30;

          when 30 =>
            uart_txd <= '0';
            tx_state <= 31;
          when 31 =>
            uart_txd <= dp(0);
            tx_state <= 32;
          when 32 =>
            uart_txd <= dp(1);
            tx_state <= 33;
          when 33 =>
            uart_txd <= dp(2);
            tx_state <= 34;
          when 34 =>
            uart_txd <= dp(3);
            tx_state <= 35;
          when 35 =>
            uart_txd <= dp(4);
            tx_state <= 36;
          when 36 =>
            uart_txd <= dp(5);
            tx_state <= 37;
          when 37 =>
            uart_txd <= dp(6);
            tx_state <= 38;
          when 38 =>
            uart_txd <= dp(7);
            tx_state <= 39;
          when 39 =>
            uart_txd <= '1';
            tx_state <= 40;

          when 40 =>
            uart_txd <= '0';
            tx_state <= 41;
          when 41 =>
            uart_txd <= tx_fifo(3)(0);
            tx_state <= 42;
          when 42 =>
            uart_txd <= tx_fifo(3)(1);
            tx_state <= 43;
          when 43 =>
            uart_txd <= tx_fifo(3)(2);
            tx_state <= 44;
          when 44 =>
            uart_txd <= tx_fifo(3)(3);
            tx_state <= 45;
          when 45 =>
            uart_txd <= tx_fifo(3)(4);
            tx_state <= 46;
          when 46 =>
            uart_txd <= tx_fifo(3)(5);
            tx_state <= 47;
          when 47 =>
            uart_txd <= tx_fifo(3)(6);
            tx_state <= 48;
          when 48 =>
            uart_txd <= tx_fifo(3)(7);
            tx_state <= 49;
          when 49 =>
            uart_txd <= '1';
            tx_state <= 50;

          when 50 =>
            uart_txd <= '0';
            tx_state <= 51;
          when 51 =>
            uart_txd <= tx_fifo(2)(0);
            tx_state <= 52;
          when 52 =>
            uart_txd <= tx_fifo(2)(1);
            tx_state <= 53;
          when 53 =>
            uart_txd <= tx_fifo(2)(2);
            tx_state <= 54;
          when 54 =>
            uart_txd <= tx_fifo(2)(3);
            tx_state <= 55;
          when 55 =>
            uart_txd <= tx_fifo(2)(4);
            tx_state <= 56;
          when 56 =>
            uart_txd <= tx_fifo(2)(5);
            tx_state <= 57;
          when 57 =>
            uart_txd <= tx_fifo(2)(6);
            tx_state <= 58;
          when 58 =>
            uart_txd <= tx_fifo(2)(7);
            tx_state <= 59;
          when 59 =>
            uart_txd <= '1';
            tx_state <= 60;

          when 60 =>
            uart_txd <= '0';
            tx_state <= 61;
          when 61 =>
            uart_txd <= tx_fifo(1)(0);
            tx_state <= 62;
          when 62 =>
            uart_txd <= tx_fifo(1)(1);
            tx_state <= 63;
          when 63 =>
            uart_txd <= tx_fifo(1)(2);
            tx_state <= 64;
          when 64 =>
            uart_txd <= tx_fifo(1)(3);
            tx_state <= 65;
          when 65 =>
            uart_txd <= tx_fifo(1)(4);
            tx_state <= 66;
          when 66 =>
            uart_txd <= tx_fifo(1)(5);
            tx_state <= 67;
          when 67 =>
            uart_txd <= tx_fifo(1)(6);
            tx_state <= 68;
          when 68 =>
            uart_txd <= tx_fifo(1)(7);
            tx_state <= 69;
          when 69 =>
            uart_txd <= '1';
            tx_state <= 70;

          when 70 =>
            uart_txd <= '0';
            tx_state <= 71;
          when 71 =>
            uart_txd <= tx_fifo(0)(0);
            tx_state <= 72;
          when 72 =>
            uart_txd <= tx_fifo(0)(1);
            tx_state <= 73;
          when 73 =>
            uart_txd <= tx_fifo(0)(2);
            tx_state <= 74;
          when 74 =>
            uart_txd <= tx_fifo(0)(3);
            tx_state <= 75;
          when 75 =>
            uart_txd <= tx_fifo(0)(4);
            tx_state <= 76;
          when 76 =>
            uart_txd <= tx_fifo(0)(5);
            tx_state <= 77;
          when 77 =>
            uart_txd <= tx_fifo(0)(6);
            tx_state <= 78;
          when 78 =>
            uart_txd <= tx_fifo(0)(7);
            tx_state <= 79;
          when 79 =>
            uart_txd <= '1';
            tx_state <= 80;

          when 49999 =>
            tx_state <= 0;

          when others =>
            tx_state <= tx_state + 1;

        end case;

      end if;
    end if;
  end process uart_tx_i;

end behavioral;
