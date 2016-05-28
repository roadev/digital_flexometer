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
@measures = []
ei = 0.7
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
        @measures << measure.chomp.to_f
        puts "measures: #{measure}"

      }

      def sum(xi)
        sum = xi.inject{ |sum, el| sum + el }.to_f
        return sum
      end

      def average_calculation(measures)
        avg = sum(measures) / measures.size
        return avg
      end

      def standard_deviation_calculation(measures, avg)
        internal_sigma = []
        measures.each do |xi|
          internal_sigma << ((avg - xi).abs)**2
          sigma = sum(internal_sigma)
          @sd = Math.sqrt(sigma/measures.size)
        end
        return @sd
      end

      def random_error(n, sd)
        re = (3 * sd)/Math.sqrt(n-1)
        return re
      end

      def abs_error(ei, re)
        abs_e = Math.sqrt(ei**2 + re**2)
        return abs_e
      end


      ws.onclose {
        puts "Conexión cerrada por el cliente"
        puts "measures_array: #{@measures.inspect}"
        csv << ["", "x (promedio): ", "#{average_calculation(@measures)}"]
        csv << ["", "Ei (E. instrumento)", "#{ei}"]
        csv << ["", "σ (desv. estándar)", "#{standard_deviation_calculation(@measures, average_calculation(@measures))}"]
        csv << ["", "Ea (E. aleatorio)", "#{random_error(@measures.size, standard_deviation_calculation(@measures, average_calculation(@measures)))}"]
        csv << ["", "Δx (E. absoluto)", "#{abs_error(ei, random_error(@measures.size, standard_deviation_calculation(@measures, average_calculation(@measures))))}"]

      }

      ws.onerror { |e|
        puts "Error: #{e.message}"
      }
    end
  }
end
