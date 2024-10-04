# frozen_string_literal: true

require 'slack-ruby-client'

namespace :slack do
  desc 'Send the latest Git commits to Slack'
  task send: :environment do
    def git_commits
      lasted_tag = `git describe --tags --abbrev=0`.strip
      if lasted_tag.empty?
        `git log --oneline -n 10`.split("\n")
      else
        `git log #{lasted_tag}..HEAD --oneline`.split("\n")
      end
    end

    def format_commits_for_slack(commits)
      formatted_commits = commits.map { |commit| "• #{commit}" }.join("\n")
      "最新のコミットログ:\n#{formatted_commits}"
    end

    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    client = Slack::Web::Client.new

    commits = git_commits
    formatted_message = format_commits_for_slack(commits)

    client.chat_postMessage(channel: '#test', text: formatted_message, as_user: true)
  end
end
