class UserAuthentication
  include Mongoid::Document
  include Mongoid::Timestamps
  field :username, type: String
  field :timezone, type: String
  field :email, type: String
  field :encrypted_password, type: String
  field :salt, type: String

  attr_accessor :password
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates_presence_of :username
  validates_presence_of :email
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  before_save :encrypt_password
  after_save :clear_password
  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end
  def clear_password
    self.password = nil
  end

  def self.authenticate(username, password)
    user = find_by(username: username)
    if user && user.encrypted_password == BCrypt::Engine.hash_secret(password, user.salt)
      user
    else
      nil
    end
  end
end