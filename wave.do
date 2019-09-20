
wave add -radix dec      top_level_tb/test_number
wave add -radix bin      top_level_tb/uut/clk
#wave add -radix bin      top_level_tb/uut/reset
wave add -radix bin      top_level_tb/uut/reset_int

#wave add -radix bin      top_level_tb/uut/adc_intfc_i/adc_cs
#wave add -radix bin      top_level_tb/uut/adc_intfc_i/adc_sck
#wave add -radix bin      top_level_tb/uut/adc_intfc_i/adc_sdi
#wave add -radix bin      top_level_tb/uut/adc_intfc_i/adc_sdo
#wave add -radix unsigned top_level_tb/cha_signal
#wave add                 top_level_tb/uut/adc_intfc_i/rx_state
#wave add -radix hex      top_level_tb/uut/adc_intfc_i/ch_buf
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/steer_fifo
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/steer_fifo(0)
#wave add -radix unsigned top_level_tb/uut/adc_intfc_i/chb_fifo
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/steer_angle
#wave add -radix dec      top_level_tb/steer_angle
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/offset_prev
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/ch_cfg
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/gear_rot
#wave add -radix dec      top_level_tb/uut/adc_intfc_i/gear_lin

#wave add -radix bin      top_level_tb/uut/can_txd
#wave add                 top_level_tb/uut/can_i/tx_state
#wave add -radix hex      top_level_tb/uut/can_i/can_arb_field
#wave add -radix hex      top_level_tb/can_i/rx_arb_field
#wave add -radix hex      top_level_tb/uut/can_i/can_data_buf
#wave add -radix hex      top_level_tb/can_i/rx_fifo
#wave add -radix hex      top_level_tb/uut/can_i/can_crc_reg
#wave add -radix hex      top_level_tb/can_i/calc_crc_field
#wave add -radix hex      top_level_tb/can_i/capt_crc_field
#wave add -radix hex      top_level_tb/uut/can_i/initial_cfg
#wave add -radix unsigned top_level_tb/uut/can_i/initial_wait

#wave add -radix bin      top_level_tb/uut/uart_i/uart_rxd
#wave add -radix bin      top_level_tb/uut/uart_i/baud_clk
#wave add -radix bin      top_level_tb/uut/uart_i/shift_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/gear_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/revs_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/revs_cfg_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/speed_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/oil_p_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/water_t_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/lap_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/lap_time_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/best_lap_rdy

#wave add -radix bin      top_level_tb/uut/uart_i/uart_rxd
#wave add -radix bin      top_level_tb/uut/uart_i/baud_clk
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(0)
#wave add -radix dec      top_level_tb/uut/uart_i/rx_state
#wave add -radix dec      top_level_tb/uut/uart_i/revs
#wave add -radix dec      top_level_tb/uut/uart_i/car_speed
#wave add -radix dec      top_level_tb/uut/uart_i/uart_gear
#wave add -radix dec      top_level_tb/uut/uart_i/force_feedback
#wave add -radix bin      top_level_tb/uut/uart_i/shift_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/gear_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/revs_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/revs_cfg_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/speed_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/oil_p_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/water_t_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/lap_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/lap_time_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/best_lap_rdy
#wave add -radix bin      top_level_tb/uut/uart_i/ff_rdy

#wave add -radix bin      top_level_tb/uut/motor_i/mot_pha_hi
#wave add -radix bin      top_level_tb/uut/motor_i/mot_pha_lo
#wave add -radix bin      top_level_tb/uut/motor_i/mot_phb_hi
#wave add -radix bin      top_level_tb/uut/motor_i/mot_phb_lo
#wave add -radix unsigned top_level_tb/uut/motor_i/count
#wave add -radix unsigned top_level_tb/uut/motor_i/motor_power

#wave add -radix bin      top_level_tb/dac0_sck
#wave add -radix bin      top_level_tb/dac0_sdo
#wave add -radix bin      top_level_tb/dac0_cs
#wave add -radix bin      top_level_tb/dac0_ldac

#wave add -radix bin      top_level_tb/uut/dac_intfc_i/tick
#wave add                 top_level_tb/uut/dac_intfc_i/tx_state

#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(0)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(1)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(2)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(3)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(4)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(5)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(6)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(7)
#wave add -radix hex      top_level_tb/uut/uart_i/rx_fifo(8)
#wave add -radix dec      top_level_tb/uut/revs_cfg
#wave add -radix dec      top_level_tb/uut/revs
#wave add -radix dec      top_level_tb/uut/car_speed

#wave add -radix bin      top_level_tb/can_i/crc_fail
#wave add -radix dec      top_level_tb/can_i/shift_lights
#wave add -radix dec      top_level_tb/can_i/uart_gear
#wave add -radix dec      top_level_tb/can_i/revs
#wave add -radix dec      top_level_tb/can_i/revs_cfg
#wave add -radix dec      top_level_tb/can_i/car_speed
#wave add -radix dec      top_level_tb/can_i/oil_pressure
#wave add -radix dec      top_level_tb/can_i/water_temp
#wave add -radix dec      top_level_tb/can_i/lap
#wave add -radix dec      top_level_tb/can_i/lap_time
#wave add -radix dec      top_level_tb/can_i/best_lap_time
#wave add -radix dec      top_level_tb/uut/can_i/can_idle
#wave add -radix dec      top_level_tb/uut/can_i/idle_cfg_msg
#wave add -radix dec      top_level_tb/uut/can_i/initial_cfg

wave add -radix dec      top_level_tb/uut/pid_i/force_feedback
wave add -radix dec      top_level_tb/uut/pid_i/motor_power
wave add -radix dec      top_level_tb/uut/pid_i/motor_current
wave add -radix dec      top_level_tb/uut/pid_i/prop_var
wave add -radix dec      top_level_tb/uut/pid_i/integ_var
wave add -radix dec      top_level_tb/uut/pid_i/deriv_var
wave add -radix dec      top_level_tb/uut/pid_i/prev_motor_current_error
#wave add -radix dec      top_level_tb/motor_i/pha_count
#wave add -radix dec      top_level_tb/motor_i/phb_count
#wave add -radix dec      top_level_tb/motor_i/hi_duration
#wave add -radix bin      top_level_tb/mot_pha_lo
#wave add -radix bin      top_level_tb/mot_phb_lo
#wave add -radix dec      top_level_tb/motor_current



restart

isim force add {/top_level_tb/uut/can_i/c_initial_wait} 999 -radix dec

#run 5ms
#run 10ms
#run 25ms
#run 50ms
#run 100ms
run 200ms
#run 1s
#run 2s
#run 5s
#run 20s

quit -f