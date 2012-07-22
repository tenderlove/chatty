require 'tusk/observable/pg'
require 'erb'

class Message < ActiveRecord::Base
  include ERB::Util

  attr_accessible :value, :who, :uid

  extend Tusk::Observable::PG

  # After users are created, notify the message bus
  after_create :notify_observers

  # Listeners will use the table name as the bus channel
  def self.channel
    table_name
  end

  def event_hash
    {
      'type'  => 'message',
      'who'   => h(who),
      'value' => imgval,
      'uid'   => h(uid)
    }
  end

  def imgval
    begin
      uri = URI(value)
      if uri.scheme == 'http'
        if uri.path =~ /\.(jpg|png|gif)$/
          "<img src=\"#{value}\" />"
        else
          "<a href=\"#{value}\">#{h(value)}</a>"
        end
      else
        h(value)
      end
    rescue
      value
    end
  end

  private

  def notify_observers
    self.class.changed
    self.class.notify_observers
  end
end
