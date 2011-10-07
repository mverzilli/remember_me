class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  has_many :schedules, :dependent => :destroy
  
  has_one :channel, :dependent => :destroy
  
  def register_channel(code)
    raise Nuntium::Exception.new("There were problems creating the channel", "Ticket code" => "Mustn't be blank") if code.blank?
    remove_old_channel
    new_channel_info = create_nuntium_channel_for code
    channel = self.build_channel :name => new_channel_info["name"], :address => new_channel_info["address"]
    channel.save!
  end
  
  def build_message(to, body)
    { :from => "remindem".with_protocol, :to => to, :body => body, :'x-remindem-user' => self.email }
  end
  
  def remove_old_channel
    channel = Channel.find_by_user_id(self.id)
    channel.destroy  unless channel.nil?
  end
  
  def create_nuntium_channel_for code
    Nuntium.new_from_config.create_channel({ 
      :name => self.email.to_channel_name, 
      :ticket_code => code, 
      :ticket_message => "This gateway will be used for reminders written by #{self.email}",
      :at_rules => [{
        'matchings' => [], 
        'actions' => [{ 'property' => 'x-remindem-user', 'value' => self.email }], 
        'stop' => false}],
      :restrictions => [{ 'name' => 'x-remindem-user', 'value' => self.email }],
      :kind => 'qst_server',
      :protocol => 'sms',
      :direction => 'bidirectional',
      :configuration => { :password => SecureRandom.base64(6) },
      :enabled => true
    })
  end
  
end
