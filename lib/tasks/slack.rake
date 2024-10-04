# frozen_string_literal: true

require 'slack-ruby-client'

namespace :slack do
  desc 'Send the latest Git commits to Slack after the latest tag for main branch'
  task send: :environment do
    def git_commits_after_latest_tag
      latest_tag = `git describe --tags --abbrev=0`.strip
      if latest_tag.empty?
        `git log main --oneline -n 10`.split("\n")
      else
        `git log #{latest_tag}..main --oneline`.split("\n")
      end
    end

    def format_commits_for_slack(commits)
      return '最新のタグ以降に新しいコミットはありません。' if commits.empty?

      formatted_commits = commits.map { |commit| "• #{commit}" }.join("\n")
      "mainブランチへの最新のタグ以降のコミット:\n#{formatted_commits}"
    end

    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    client = Slack::Web::Client.new

    commits = git_commits_after_latest_tag
    formatted_message = format_commits_for_slack(commits)

    client.chat_postMessage(channel: '#test', text: formatted_message, as_user: true)

    puts '最新のタグ以降のコミットログがSlackに送信されました。'
  end
end
