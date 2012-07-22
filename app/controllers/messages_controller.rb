require 'securerandom'

class MessagesController < ApplicationController
  include ERB::Util

  def show
    respond_to do |format|
      format.html
      format.json do
        #joined = ! session.key?(:id)
        #session[:id]   ||= SecureRandom.urlsafe_base64
        #session[:name] ||= "Guest#{session[:id].slice(0, 2)}"
      end
    end
  end

  def create
    render :nothing => true
  end
end
