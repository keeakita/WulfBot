require 'active_record'

module WulfBot::Plugin::Points

  # Connect to the database
  db_name =  ENV['RAILS_ENV'] || 'development'
  ActiveRecord::Base.establish_connection(
    YAML::load(
      File.open('db/config.yml')
    )[db_name])

  # An array of {group userid time} hashes tracking when a given user voted in
  # a given group most recently. Used for rate limiting.
  @@last_voted = []

  # Time to wait (in seconds) before letting a user vote again
  VOTE_COOLDOWN = 7200

  # An ActiveRecord class representing the score for a given user
  class PointRecord < ActiveRecord::Base

    def score
      self.upvotes - self.downvotes
    end

    def addpoint
      self.upvotes += 1
    end

    def addpoint!
      addpoint
      save!
    end

    def rmpoint
      self.downvotes += 1
    end

    def rmpoint!
      rmpoint
      save!
    end

    def to_s
      "#{user}: #{score} (+#{upvotes}/-#{downvotes})"
    end
  end

  def self.getPointRecord(group, user)
    PointRecord.where(group: group, user: user.downcase).take
  end

  def self.topScores(group, number=5)
    PointRecord.where(group: group)
               .select('*, upvotes-downvotes as score')
               .order('score DESC')
               .limit(number)
  end

  def self.bottomScores(group, number=5)
    PointRecord.where(group: group)
               .select('*, upvotes-downvotes as score')
               .order('score ASC')
               .limit(number)
  end

  # Checks if the given user is allowed to vote for the target in the group
  # based on the rate limit.
  def self.canVote?(group, userid)
    vote_time = Time.now

    records = @@last_voted.select do |item|
      group == item[:group] && userid == item[:userid]
    end

    return true if records.empty?
    return vote_time > (records.first[:time] + VOTE_COOLDOWN)
  end

  # Store a successful vote attempt in the rate limit tracking caches.
  def self.registerVoteTime(group, userid)
    # Search for an existing record and update the time if applicable
    records = @@last_voted.select do |item|
      group == item[:group] && userid == item[:userid]
    end

    if (records.empty?)
      # Create a new record
      @@last_voted << {group: group, userid: userid, time: Time.now}
    else
      # Update existing record
      records.first[:time] = Time.now
    end
  end


  # /addpoint and /rmpoint
  on_add_or_rm_points = Proc.new do |message|
    /\A\/(add|rm)point(@WulfBot)?\s+(.+)/i =~ message.text
      mode = $1
      target = $3

      if mode.nil? || target.nil?
        WulfBot::send_limited(message.chat.id,
                     "Please tell me what you want to vote on.")
      # Check if the sender can vote
      elsif !(canVote?(message.chat.id, message.from.id))

        WulfBot::send_limited(message.chat.id,
                     "Sorry, you need to wait before voting again.")
      else
        # Check for no existing record
        record = getPointRecord(message.chat.id, target.downcase)
        if (record.nil?)
          record = PointRecord.create(
            group: message.chat.id,
            user: target.downcase)
        end

        if (mode == "add")
          record.addpoint!
        else
          record.rmpoint!
        end

        # Register this vote attempt to the rate limit checker
        registerVoteTime(message.chat.id, message.from.id)

        WulfBot::send_limited(message.chat.id, record.to_s)
      end
    end

    WulfBot::register_command(command: "addpoint", &on_add_or_rm_points)
    WulfBot::register_command(command: "rmpoint", &on_add_or_rm_points)

    WulfBot::register_command(command: "points") do |message|
      /\A\/points(@WulfBot)?\s+(.+)/i =~ message.text
      user = $2

      if user.nil?
        WulfBot::send_limited(message.chat.id,
                              "Please specify which score you want to check")
      else
        record = getPointRecord(message.chat.id, user.downcase)

        # Check for no existing record
        unless (record.nil?)
          WulfBot::send_limited(message.chat.id, record.to_s)
        else
          WulfBot::send_limited(message.chat.id, "#{user} has no points.")
        end
      end
    end

    WulfBot::register_command(command: "top") do |message|
      records = topScores(message.chat.id)

      resp = "Top 5 scores for this chat:\n"
      records.each do |record|
        resp += record.to_s + "\n"
      end

      WulfBot::send_limited(message.chat.id, resp)
    end

    WulfBot::register_command(command: "bottom") do |message|
      records = bottomScores(message.chat.id)

      resp = "Bottom 5 scores for this chat:\n"
      records.each do |record|
        resp += record.to_s + "\n"
      end

      WulfBot::send_limited(message.chat.id, resp)
    end
end
