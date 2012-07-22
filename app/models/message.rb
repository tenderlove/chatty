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
      'value' => h(value),
      'uid'   => h(uid)
    }
  end

  private

  def notify_observers
    self.class.changed
    self.class.notify_observers
  end
end
