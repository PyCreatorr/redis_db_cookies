class Preference < ApplicationRecord
  belongs_to :user

  def self.update_user_preferences(user, preferences)
    puts "Preferences model user.preference.update(user=#{user}, preferences=#{preferences})"    
    #user.preference.update(**preferences)

    user.preference[:post_order] = preferences[:post_order]

    @redis = RedisService.set_redis()

    # Set the user into the redis db. Register user
    @redis.hSet(RedisPreferenceService.usersKey(user.id), {post_order: preferences[:post_order]})

    @redis.close()

  end
  
end
