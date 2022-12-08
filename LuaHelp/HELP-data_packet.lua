data_packet() --> packet

You can index a data_packet like a table.
-------------------------------------------------
packet.PORT --> integer
packet.SENDER --> string
packet.DATA --> string
packet.NBYTE --> integer
packet.SWEEP_COUNT --> integer
packet.TX --> integer
packet.RX --> integer
packet.TX_PORT --> integer
packet.RX_PORT --> integer
packet.GAIN -->	integer
packet.PROCESS_INDEX --> integer

Assignmentspacket..
-------------------------------------------------
packet.PORT = integer
packet.SENDER = string
packet.DATA = string
packet.NBYTE = integer
packet.SWEEP_COUNT = integer
packet.TX = integer
packet.RX = integer
packet.TX_PORT = integer
packet.RX_PORT = integer
packet.GAIN =	integer
packet.PROCESS_INDEX = integer

print(packet) --> data_packet(size_of_packet_buffer)
