class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :preference


  def self.update_user_preferences(user, preferences)
    puts "User model user.preference.update(user=#{user}, preferences=#{preferences})"
    user.preference.update(preferences)
  end


end
