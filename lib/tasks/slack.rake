# frozen_string_literal: true

namespace :slack do
  task send: :environment do
    # 最新の10件のコミットを取得
    def fetch_git_commits
      # git logで最新の10件のコミットを取得
      `git log --oneline -n 10`.split("\n")
    end

    # Slackに送信するメッセージを作成
    def build_slack_message(commits)
      "最新コミット:\n#{commits.join("\n")}"
    end

    # Slackにメッセージを送信
    def post_to_slack(webhook_url, message)
      uri = URI.parse(webhook_url)
      header = { 'Content-Type' => 'application/json' }
      payload = { text: message }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = payload
      http.request(request)
    end

    # コミットメッセージをSlackに送信する
    def send_to_slack(commits)
      webhook_url = ENV['SLACK_WEBHOOK_URL'] # 環境変数からWebhook URLを取得
      if webhook_url.nil? || webhook_url.empty?
        puts 'Slack Webhook URLが設定されていません'
        return
      end

      message = build_slack_message(commits)
      response = post_to_slack(webhook_url, message)

      if response.code == '200'
        puts 'メッセージがSlackに送信されました'
      else
        puts "Slackへの送信に失敗しました: #{response.body}"
      end
    end

    # コミットの取得とSlackへの送信を実行
    commits = fetch_git_commits
    send_to_slack(commits)
  end
end
