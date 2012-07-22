require 'securerandom'
require 'mutex_m'

class MessagesController < ApplicationController
  include ERB::Util

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
    respond_to do |format|
      format.html
      format.json do
        begin
          response.headers['Content-Type'] = 'text/event-stream'
          ss    = ServerSend.new response.stream
          queue = Queue.new

          Message.add_observer Listener.new(Message.maximum(:id), queue)

          session[:id]   ||= SecureRandom.urlsafe_base64
          session[:name] ||= "Guest#{session[:id].slice(0, 2)}"

          while event = queue.pop
            ss.write event.event_hash
          end
        ensure
          ss.close
        end
      end
    end
  end

  def create
    if session[:name]
      Message.create! :value => params[:message], :who => session[:name]
    end

    render :nothing => true
  end
end
