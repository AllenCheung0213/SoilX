Currently, only UDP socket type is supported.

socket.open(port{, timeout = 200}) --> socket
socket.close() --> VOID

These are the broadcast version of send...

socket.send(socket, message) --> nchar
socket.send(socket, message, port) --> characters_sent

Use these versions of send to address a specific target...

socket.send(socket, message, address) --> nchar
socket.send(socket, message, address, port) --> characters_sent

socket.receive(socket) --> nchar, senderIP, senderPort, message

These selectors operate directly on a socket object...

socket.SOCKET --> socket
socket.PORT --> port
socket.TIMEOUT --> timeout
socket.BROADCAST_ADDRESS --> address

print(socket) --> socket(port, timeout)

