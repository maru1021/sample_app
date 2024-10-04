# frozen_string_literal: true

require 'slack-ruby-client'

namespace :slack do
  desc 'Send the latest Git commits to Slack after the latest tag for main branch'
  task send: :environment do
    # 最新のタグを取得し、そのタグ以降のコミットを取得
    def git_commits_after_latest_tag
      latest_tag = `git describe --tags --abbrev=0`.strip
      if latest_tag.empty?
        `git log main --oneline -n 10`.split("\n") # タグがない場合は直近10件を取得
      else
        `git log #{latest_tag}..main --oneline`.split("\n") # 最新のタグ以降のmainへのコミット
      end
    end

    # コミットデータをSlackに送信するために整形
    def format_commits_for_slack(commits)
      return '最新のタグ以降に新しいコミットはありません。' if commits.empty?

      formatted_commits = commits.map { |commit| "• #{commit}" }.join("\n")
      "mainブランチへの最新のタグ以降のコミット:\n#{formatted_commits}"
    end

    # Slackの設定
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    client = Slack::Web::Client.new

    # 最新のタグ以降のコミットを取得し、整形
    commits = git_commits_after_latest_tag
    formatted_message = format_commits_for_slack(commits)

    # Slackにメッセージを送信
    client.chat_postMessage(channel: '#test', text: formatted_message, as_user: true)

    puts '最新のタグ以降のコミットログがSlackに送信されました。'
  end
end
