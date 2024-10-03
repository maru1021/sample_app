# frozen_string_literal: true

namespace :slack do
  task send: :environment do
    def fetch_git_commits
      lasted_tag = `git describe --tags --abbrev=0`.strip
      if lasted_tag.empty?
        `git log --oneline -n 10`.split("\n")
      else
        `git log #{lasted_tag}..HEAD --oneline -n 10`.split("\n")
      end
    end

    def build_slack_message(commits)
      "最新コミット:\n#{commits.join("\n")}"
    end

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

    def send_to_slack(commits)
      webhook_url = 'https://hooks.slack.com/services/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'
      message = build_slack_message(commits)
      response = post_to_slack(webhook_url, message)
      puts response.code

      if response.code == '200'
        puts 'メッセージがSlackに送信されました'
      else
        puts "Slackへの送信に失敗しました: #{response.body}"
      end
    end

    commits = fetch_git_commits
    send_to_slack(commits)
  end
end
