require 'uri'
require 'net/http'
require 'json'

100.times.map { |i|
  puts "### client #{i}"

  Thread.new {
    uri = URI('http://localhost:9292/messages/show.json')

    http = Net::HTTP.new uri.host, uri.port
    http.start do |http|
      request = Net::HTTP::Get.new uri.request_uri

      http.request(request) do |resp|
        resp.read_body do |chunk|
          if chunk =~ /^data: (.*)$/
            begin
              p JSON.load($1)
            rescue JSON::ParserError
              p $1
            end
          end
        end
      end
    end
  }
}.each(&:join)
