
c = 299792458
power_of_r = 4

dist = 30
rcs = 1
freq = 500E6
print("freq", freq)

tx_gain_dbi = 0
rx_gain_dbi = 0

tx_gain = 10^(tx_gain_dbi/10)
rx_gain = 10^(rx_gain_dbi/10)

print("path loss", 10*math.log10((tx_gain * rx_gain * rcs * (c / freq)^2) / ((4*PI)^3 * dist^(power_of_r))))
print(tx_gain_dbi + rx_gain_dbi 
						+ 10*math.log10(rcs) - 20*math.log10(freq) 
						- 10*power_of_r*math.log10(dist) 
						- 30*math.log10(4*PI) + 20*math.log10(c))