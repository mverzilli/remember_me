class Channel < ActiveRecord::Base
  belongs_to :user
  before_destroy :remove_channel_from_nuntium
  
  def remove_channel_from_nuntium
    p name
    p self
    Nuntium.new_from_config.delete_channel name
  end
  
end
