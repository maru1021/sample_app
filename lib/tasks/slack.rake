# frozen_string_literal: true

require 'slack-ruby-client'
require 'jira-ruby'
require_relative '../../lib/clients/git_client'
require_relative '../../lib/clients/jira_client'
require_relative '../../lib/clients/slack_notifier'

namespace :slack do
  desc 'Send the latest Git commits to Slack with Jira information'
  task send: :environment do
    git_client = GitClient
    jira_client = JiraClient
    slack_notifier = SlackNotifier.new

    branch_name = git_client.current_branch
    commits = git_client.commits_since_latest_tag(branch_name)

    if commits.empty?
      slack_notifier.send_message('#test', '最新のタグ以降に新しいコミットはありません。')
      puts '最新のタグ以降に新しいコミットはありません。'
      next
    end

    formatted_message = commits.map do |commit|
      jira_id = jira_client.extract_jira_id(commit[:branch])
      jira_info = if jira_id
                    issue_info = jira_client.fetch_jira_issue_info(jira_id)
                    issue_info ? jira_client.format_jira_info(issue_info) : 'Jira情報が見つかりません'
                  else
                    'Jira IDが見つかりません'
                  end

      hash = commit[:hash][0, 10].ljust(10)             # ハッシュを10文字に制限
      message = commit[:message][0, 20].ljust(20)       # メッセージを20文字に制限
      branch = commit[:branch][0, 20].ljust(20)         # ブランチ名を20文字に制限
      "#{hash} #{message} #{branch} #{jira_info}"
    end.join("\n")

    slack_notifier.send_message('#test', formatted_message)
    puts '最新のタグ以降のコミットログがSlackに送信されました。'
  end
end
