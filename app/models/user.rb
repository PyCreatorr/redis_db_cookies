class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :encryptable

  has_one :preference

  # has_secure_password


  def self.update_user_preferences(user, preferences)
    puts "User model user.preference.update(user=#{user}, preferences=#{preferences})"
    user.preference.update(preferences)
  end

  def decrypted_password  
    Devise::Encryptable::Encryptors::Aes256.decrypt(encrypted_password, Devise.pepper)
  end  


end
