class HomericaController < ApplicationController
  def index
    respond_to do |format|
      format.js
    end
    if current_user.homerica
      current_user.update(homerica: false)
    else
      current_user.update(homerica: true)
    end
  end
end
