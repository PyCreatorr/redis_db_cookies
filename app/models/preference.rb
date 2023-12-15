class Preference < ApplicationRecord
  belongs_to :user

  def self.update_user_preferences(user, preferences)
    puts "Preferences model user.preference.update(user=#{user}, preferences=#{preferences})"
    
    user.preference.update(**preferences)
  end
  
end
