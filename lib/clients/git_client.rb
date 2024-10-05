# frozen_string_literal: true

# GitHubからのデータの取得
class GitClient
  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def self.latest_tag
    `git describe --tags --abbrev=0`.strip
  end

  def self.commits_since_latest_tag(branch)
    latest_tag = self.latest_tag
    commits = if latest_tag.empty?
                `git log #{branch} --pretty=format:"%H %s" -n 10`.split("\n")
              else
                `git log #{latest_tag}..#{branch} --pretty=format:"%H %s"`.split("\n")
              end
    commits.map { |commit| parse_commit(commit) }.uniq { |commit| commit[:hash] }
  end

  # マージコミットを解析し、重複を排除
  def self.parse_commit(commit)
    hash, message = commit.split(' ', 2)

    if message.include?('Merge pull request')
      merge_info = `git log -1 --pretty=format:"%P" #{hash}`.split(' ')
      parent_commit = merge_info[1] # 2番目の親がマージ元
      parent_message = `git log -1 --pretty=format:"%s" #{parent_commit}`.strip
      parent_hash = `git log -1 --pretty=format:"%H" #{parent_commit}`.strip

      merge_branch = `git name-rev --name-only #{parent_commit}`.strip
      merge_branch.gsub!(%r{remotes/origin/}, '')
      merge_branch.gsub!(/~\d+/, '')

      { hash: parent_hash, message: parent_message, branch: merge_branch }
    else
      { hash:, message:, branch: current_branch }
    end
  end
end
