require 'tusk/observable/pg'

class Message < ActiveRecord::Base
  attr_accessible :value, :who

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
      'who'   => who,
      'value' => value
    }
  end

  private

  def notify_observers
    self.class.changed
    self.class.notify_observers
  end
end
