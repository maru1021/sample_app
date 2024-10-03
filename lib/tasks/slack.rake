# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

def fetch_git_commits
  lasted_tag = `git describe --tags --abbrev=0`.strip
  if lasted_tag.empty?
    `git log --oneline -n 10`.split("\n")
  else
    `git log #{lasted_tag}..HEAD --oneline`.split("\n")
  end
end

def build_slack_message(commits)
  {
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: '最近のcommit一覧:'
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "```\n#{commits.join("\n")}\n```"
        }
      }
    ]
  }.to_json
end

def post_to_slack(webhook_url, message)
  uri = URI(webhook_url)
  header = { 'Content-Type': 'application/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri, header)
  request.body = message

  response = http.request(request)
  puts response.body
end

def send_to_slack
  commits = fetch_git_commits
  message = build_slack_message(commits)
  webhook_url = ENV['SLACK_WEBHOOK_URL']
  post_to_slack(webhook_url, message)
end

send_to_slack
