# encoding: utf-8
#!/usr/bin/ruby

require 'em-websocket'
require 'rubygems'
require 'serialport'
require 'socket'
require 'time'
require 'csv'

port_str = '/dev/ttyACM0' #In windows OS search for COM port
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
print "Conectando...\n"
sleep 3
print "¡Conectado a Arduino!\n"

myhost = "0.0.0.0"
myport = 8000

CSV.open("file.csv", "wb") do |csv|

  csv << ["distancia", "unidad"]

  EM.run {
    puts "Esperando requests en el puerto #{myport}..."

    EM::WebSocket.run(host: myhost, port: myport, debug: false) do |ws|
      ws.onopen do |handshake|
        path = handshake.path
        param = handshake.query
        origin = handshake.origin
        puts "¡Conexión Establecida!"
      end



      ws.onmessage { |msg|
        @sp.write("#{msg}\n");
        sleep(0.2)
        measure = @sp.gets
        sleep(0.2)
        if measure
          ws.send measure
        end

        csv << ["#{measure.chomp}", "cm", ""]
        puts measure

      }



      ws.onclose {
        puts "Conexión cerrada por el cliente"
      }

      ws.onerror { |e|
        puts "Error: #{e.message}"
      }
    end
  }
end
