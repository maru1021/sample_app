class JiraClient
  JIRA_OPTIONS = {
    username: ENV['JIRA_USERNAME'],
    password: ENV['JIRA_API_TOKEN'],
    site: 'https://poprockguitarmaru.atlassian.net',
    context_path: '',
    auth_type: :basic,
    use_ssl: true
  }.freeze

  def self.extract_jira_id(branch_name)
    match = branch_name.match(/SCRUM-\d{1,5}/)
    match[0] if match
  end

  def self.fetch_jira_issue_info(jira_id)
    return nil unless jira_id

    client = JIRA::Client.new(JIRA_OPTIONS)

    issue = client.Issue.find(jira_id)
    {
      assignee: issue.assignee ? issue.assignee.displayName : '未割り当て',
      status: issue.status.name
    }
  rescue JIRA::HTTPError => e
    puts "Jiraリクエストエラー: #{e.message}"
    nil
  rescue StandardError => e
    puts "予期しないエラー: #{e.message}"
    nil
  end

  def self.format_jira_info(jira_issue)
    assignee = jira_issue[:assignee] || '未割り当て'
    status = jira_issue[:status] || 'ステータスなし'
    "担当者: #{assignee}, ステータス: #{status}"
  end
end
