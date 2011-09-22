class TourController < ApplicationController
  
  def show
    
    render params[:page_number]
    
  end
  
end