# Handles the User and ensures that it is linked to Canvas by way of a #CanvasUsers
# #Student and #Teacher are aliases for this class
class User < ActiveRecord::Base
  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
										:path => "users/:attachment/:id_partition/:style/:filename",
										:url => "/dynamic/users/avatars/:id_partition/:style/:basename.:extension",
                    :default_url => "/assets/:style/avatar.png", :storage => :redis

	validates_attachment :avatar, content_type: { content_type: /\Aimage\/.*\Z/ }

  encrypt_with_public_key :secret,
                          :key_pair => Rails.root.join('config', 'strongbox', 'keypair.pem')
  encrypt_with_public_key :title,
                          :key_pair => Rails.root.join('config', 'strongbox', 'keypair.pem')
  encrypt_with_public_key :first_name,
                          :key_pair => Rails.root.join('config', 'strongbox', 'keypair.pem')
  encrypt_with_public_key :last_name,
                          :key_pair => Rails.root.join('config', 'strongbox', 'keypair.pem')

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :authy_authenticatable,
         :confirmable, :lockable # enabling with ripple causes an infinite loop
  #, :validatable

  validates_presence_of :email, :encrypted_password

  validates :password, presence: true, length: {minimum: 8}, on: :create
  validates :password_confirmation, presence: true, on: :create

  after_commit CanvasUsers

  attr_accessible :title,
                  :first_name,
                  :last_name,
                  :email,
                  :username,
                  :description,
                  :hidden,
                  :authy_id,
                  :authy_enabled,
                  :password,
                  :password_confirmation,
                  :encrypted_password,
                  :current_sign_in_at,
                  :last_sign_in_at,
                  :current_sign_in_ip,
                  :last_sign_in_ip,
                  :sign_in_count,
                  :confirmed_at,
                  :confirmation_token,
                  :confirmation_sent_at,
                  :remember_me,
                  :remember_created_at,
                  :filename,
                  :content_type,
                  :binary_data,
                  :encrypted_title,
                  :encrypted_last_name,
                  :encrypted_first_name

  has_and_belongs_to_many :courses
  has_one :cart
  has_many :orders
  has_one :canvas_user

  def destroy
    self.hidden = 1
  end

  def self.find_by_id(id)
    User.find(id)
  end

  def encrypted_title
    self.title.decrypt Devise.secret_key
  end

  def encrypted_title= input
    self.title = input
  end

  def encrypted_first_name
    self.first_name.decrypt Devise.secret_key
  end

  def encrypted_first_name= input
    self.first_name = input
  end

  def encrypted_last_name
    self.last_name.decrypt Devise.secret_key
  end

  def encrypted_last_name= input
    self.last_name = input
  end
end
