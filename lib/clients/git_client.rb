class GitClient
  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def self.latest_tag
    `git describe --tags --abbrev=0`.strip
  end

  # マージコミットを含むコミットログを取得
  def self.commits_since_latest_tag(branch)
    latest_tag = self.latest_tag
    commits = if latest_tag.empty?
                `git log #{branch} --pretty=format:"%H %s" -n 10`.split("\n")
              else
                `git log #{latest_tag}..#{branch} --pretty=format:"%H %s"`.split("\n")
              end
    commits.map { |commit| parse_commit(commit) }
  end

  # マージコミットの情報を解析
  def self.parse_commit(commit)
    hash, message = commit.split(' ', 2)

    if message.include?('Merge pull request')
      # マージコミットの場合、マージ元の2番目の親コミットを取得
      merge_info = `git log -1 --pretty=format:"%P" #{hash}`.split(' ')
      parent_commit = merge_info[1] # 2番目の親がマージ元
      merge_branch = `git name-rev --name-only #{parent_commit}`.strip
      parent_message = `git log -1 --pretty=format:"%s" #{parent_commit}`.strip
      parent_hash = `git log -1 --pretty=format:"%H" #{parent_commit}`.strip
      { hash: parent_hash, message: parent_message, branch: merge_branch }
    else
      { hash:, message:, branch: current_branch }
    end
  end
end
