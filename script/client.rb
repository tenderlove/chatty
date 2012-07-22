require 'uri'
require 'net/http'
require 'json'
require 'thread'
require 'sphero'

queue = Queue.new

begin
  sphero = Sphero.new "/dev/tty.Sphero-PRG-RN-SPP"
rescue Errno::EBUSY
  p :wtf
  retry
end

trap(:INT) do
  sphero.stop
  exit
end

Thread.new do
  heading = 0

  while msg = queue.pop
    if msg['value'] =~ /\/sphero\s*(.*$)/
      cmd = $1
      p :cmd => cmd
      case cmd
      when 'go' then sphero.roll(125, heading)
      when 'left'
        heading -= 90
        sphero.heading = heading
      when 'right'
        heading += 90
        sphero.heading = heading
      when 'stop'
        sphero.stop
      when 'ping'
        sphero.ping
      end
    end
  end
end

Thread.new do
  loop do
    queue.push({ 'value' => '/sphero ping' })
    sleep 1
  end
end

uri = URI('http://chat.interhub.net:9292/messages/show.json')

begin
  http = Net::HTTP.new uri.host, uri.port
  http.start do |http|
    request = Net::HTTP::Get.new uri.request_uri

    http.request(request) do |resp|
      resp.read_body do |chunk|
        if chunk =~ /^data: (.*)$/
          begin
            queue << JSON.load($1)
          rescue JSON::ParserError
            p $1
          end
        end
      end
    end
  end
rescue Net::ReadTimeout
  retry
end
