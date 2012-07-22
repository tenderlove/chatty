require 'securerandom'
require 'mutex_m'

class MessagesController < ApplicationController
  class ServerSend
    def initialize io
      @io = io
    end

    def write object
      @io.write "retry: 100\n"
      @io.write "data: #{JSON.dump(object)}\n\n"
    end

    def close
      @io.close
    end
  end

  class Listener
    include Mutex_m

    def initialize last_id, q
      super()
      @queue   = q
      @last_id = last_id
    end

    def update
      synchronize do
        messages = Message.where('id > ?', @last_id).sort_by(&:id)
        @last_id = messages.last.id
        messages.each { |m| @queue.push m }
      end
    end
  end

  def show
    session[:id]   ||= SecureRandom.urlsafe_base64
    session[:name] ||= "Guest"

    respond_to do |format|
      format.html
      format.json do
        begin
          response.headers['Content-Type'] = 'text/event-stream'
          ss       = ServerSend.new response.stream
          queue    = Queue.new
          observer = Listener.new(Message.maximum(:id), queue)

          Message.add_observer observer

          Message.limit(15).order("id desc").all.reverse_each do |m|
            hash       = m.event_hash
            hash['me'] = m.uid == session[:id] ? 'yes' : 'no'
            ss.write hash
          end

          while event = queue.pop
            hash       = event.event_hash

            next if event.uid == session[:id]

            hash['me'] = 'no'
            ss.write hash
          end
        ensure
          Message.delete_observer observer
          ss.close
        end
      end
    end
  end

  def create
    return render :nothing => true unless session[:name] && session[:id]

    name    = session[:name]
    message = params[:message]

    if message =~ /^\/nick\s*(.*)$/
      message = "changed name to #{$1}"

      session[:name] = $1
    end

    Message.create! :value => message,
                    :who   => name,
                    :uid   => session[:id]

    render :nothing => true
  end
end
