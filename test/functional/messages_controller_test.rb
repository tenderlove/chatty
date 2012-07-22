require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  def test_show
    get :show
  end
end
