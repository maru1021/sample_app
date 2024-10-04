# frozen_string_literal: true

require 'slack-ruby-client'

namespace :slack do
  desc 'Send the latest Git commits to Slack'
  task send: :environment do
    # 現在のブランチ名を取得
    def current_branch
      branch = `git rev-parse --abbrev-ref HEAD`.strip
      branch == 'HEAD' ? 'main' : branch # デタッチされている場合はmainとする
    end

    # 一番古いコミットメッセージと最新のコミットハッシュを取得
    def git_commits
      branch = current_branch

      # 一番古いコミットメッセージ
      oldest_commit_message = `git log --reverse --pretty=format:"%s" #{branch} | head -n 1`.strip

      # 最新のコミットハッシュ
      latest_commit_hash = `git rev-parse HEAD`.strip

      { branch:, latest_commit_hash:, oldest_commit_message: }
    end

    # Slackに送信するために整形
    def format_commits_for_slack(commits)
      "ブランチ: #{commits[:branch]}\n" \
      "最新のコミットハッシュ: #{commits[:latest_commit_hash]}\n" \
      "一番古いコミットメッセージ: #{commits[:oldest_commit_message]}"
    end

    # Slackの設定
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    client = Slack::Web::Client.new

    # コミット情報を取得して整形
    commits = git_commits
    formatted_message = format_commits_for_slack(commits)

    # Slackにメッセージを送信
    client.chat_postMessage(channel: '#test', text: formatted_message, as_user: true)
  end
end
