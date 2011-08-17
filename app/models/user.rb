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
    
    old_channel = Channel.find_by_user_id(self.id)
    unless old_channel.nil?
      @nuntium.delete_channel old_channel.name
      old_channel.destroy 
    end
    
    channel_password = generate_channel_password
    
    channel_info = @nuntium.create_channel({ 
      :name => self.email.to_channel_name, 
      :ticket_code => code, 
      :ticket_message => "This phone will be used for reminders written by #{self.email}",
      :at_rules => [{
        'matchings' => [], 
        'actions' => [{ 'property' => 'x-remindem-user', 'value' => self.email }], 
        'stop' => false}],
      :restrictions => [{ 'name' => 'x-remindem-user', 'value' => self.email }],
      :kind => 'qst_server',
      :protocol => 'sms',
      :direction => 'bidirectional',
      :configuration => { :password => channel_password },
      :enabled => true
    })
    
    channel = self.build_channel :name => channel_info[:name], :address => channel_info[:address]
    channel.save!
  end
  
private

  def generate_channel_password
    'secret'
  end
end
