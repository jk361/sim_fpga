
library ieee;
use ieee.std_logic_1164.all;

package components_pkg is

  component reset_rtl
  port(
    clk       : in  std_ulogic;
    reset_in  : in  std_ulogic;
    reset_out : out std_ulogic
    );
  end component reset_rtl;

  component uart_rtl
  port(
    clk            : in std_logic;
    reset          : in std_logic;
    uart_rxd       : in std_logic;
    uart_txd       : out std_logic;
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
  end component uart_rtl;

  component adc_intfc_rtl
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
  end component adc_intfc_rtl;

  component dac_intfc_rtl
  port(
    clk         : in  std_ulogic;
    reset       : in  std_ulogic;
    wheel_angle : in  integer;
    dac0_sck    : out std_ulogic;
    dac0_sdo    : out std_ulogic;
    dac0_cs     : out std_ulogic;
    dac0_ldac   : out std_ulogic;
    dac1_sck    : out std_ulogic;
    dac1_sdo    : out std_ulogic;
    dac1_cs     : out std_ulogic;
    dac1_ldac   : out std_ulogic
    );
  end component dac_intfc_rtl;

  component can_rtl
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
  end component can_rtl;

  component motor_rtl
  port(
    clk         : in std_logic;
    reset       : in std_logic;
    motor_power : in integer;
    mot_pha_hi  : out std_ulogic;
    mot_pha_lo  : out std_ulogic;
    mot_phb_hi  : out std_ulogic;
    mot_phb_lo  : out std_ulogic
    );
  end component motor_rtl;

  component debug_uart_comp is
  port(
    clk      : in  std_ulogic;
    reset    : in  std_ulogic;
    uart_txd : out std_ulogic;
    input    : in  integer
    );
  end component debug_uart_comp;

  component pid_rtl is
  port(
    clk            : in  std_ulogic;
    reset          : in  std_ulogic;
    force_feedback : in  integer;
    motor_current  : in  integer;
    motor_power    : out integer
    );
  end component pid_rtl;

end package components_pkg;
