data_scan.size(scan) --> |scan|

data_scan.get_header(scan) --> FRAME, SWEEP, TX, RX, TIMESTAMP

scan[i] = complex_number
complex_number = scan[i]

data_scan.append(scan, complex_number) --> void

Note: Right hand only.

re = scan[i][1] --> re part of the ith scan element
im = scan[i][2] --> im part of the ith scan element

#scan --> |scan|

These selectors operate directly on a data_scan object...
-------------------------------------------------
scan.FRAME_NUMBER --> integer
scan.SWEEP_NUMBER --> integer
scan.TX --> integer
scan.RX --> integer
scan.TX_PORT --> integer
scan.RX_PORT --> integer
scan.TIMESTAMP --> number
scan.GAIN --> integer
scan.SIZE --> integer
scan.DATA --> complex_vector
scan.FORMAT --> "Fr Sw Tx(Tp) Rx(Rp) Ts"
scan.GPS_HEADING --> number
scan.GPS_TIME_STATUS --> integer
scan.GPS_WEEK --> integer
scan.GPS_MILLISECOND --> integer
scan.POS_LATITUDE --> number
scan.POS_LONGITUDE --> number
scan.POS_HEIGHT --> number
scan.UTM_NORTHING --> number
scan.UTM_EASTING --> number
scan.UTM_HEIGHT --> number
scan.ENCODER_LSE --> integer
scan.ENCODER_RSE --> integer
scan.ENCODER_FLIPPER --> integer
scan.ENCODER_X --> number
scan.ENCODER_Y --> number
scan.ENCODER_DISTANCE --> number
scan.ENCODER_THETA --> number
scan.ENCODER_VELOCITY --> number
scan.ENCODER_TURN_RATE --> number
scan.SWEEP_DELAY --> number

These selectors can be directly assigned...
-------------------------------------------------
scan.FRAME_NUMBER  = integer
scan.SWEEP_NUMBER  = integer
scan.TX = integer
scan.RX = integer
scan.TX_PORT = integer
scan.RX_PORT = integer
scan.TIMESTAMP = number
scan.GAIN = integer
scan.DATA = complex_vector
scan.GPS_HEADING = number
scan.GPS_TIME_STATUS = integer
scan.GPS_WEEK = integer
scan.GPS_MILLISECOND = integer
scan.POS_LATITUDE = number
scan.POS_LONGITUDE = number
scan.POS_HEIGHT = number
scan.UTM_NORTHING = number
scan.UTM_EASTING = number
scan.UTM_HEIGHT = number
scan.ENCODER_LSE = integer
scan.ENCODER_LSE  = integer
scan.ENCODER_RSE = integer
scan.ENCODER_FLIPPER = integer
scan.ENCODER_X = number
scan.ENCODER_Y = number
scan.ENCODER_DISTANCE = number
scan.ENCODER_THETA = number
scan.ENCODER_VELOCITY = number
scan.ENCODER_TURN_RATE = number
scan.SWEEP_DELAY = number


print(scan) --> data_scan(data_scan: #scan)
data_scan.format() --> "Fr Sw Tx(Tp) Rx(Rp) Ts"




