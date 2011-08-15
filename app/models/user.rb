class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  has_many :schedules, :dependent => :destroy
  
  has_one :channel, :dependent => :destroy
  
  def register_channel(code)
    @nuntium = Nuntium.new_from_config
    
    @nuntium.delete_channel self.channel.name unless self.channel.nil?
    
    channel_info = @nuntium.create_channel({ 
      :name => self.email.to_channel_name, 
      :ticket_code => code, 
      :ticket_message => "This phone will be used for reminders written by #{self.email}"
    })
    
    channel = self.build_channel :name => channel_info[:name], :address => channel_info[:address]
    channel.save!
    
  end
end
