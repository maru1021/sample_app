class GitClient
  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def self.latest_tag
    `git describe --tags --abbrev=0`.strip
  end

  # コミットログの取得（マージ元ブランチを含む）
  def self.commits_since_latest_tag(branch)
    latest_tag = self.latest_tag
    commits = if latest_tag.empty?
                `git log #{branch} --pretty=format:"%H %s" -n 10 --merges`.split("\n")
              else
                `git log #{latest_tag}..#{branch} --pretty=format:"%H %s" --merges`.split("\n")
              end
    commits.map { |commit| parse_commit(commit) }
  end

  # マージ元ブランチ情報を取得するメソッド
  def self.parse_commit(commit)
    hash, message = commit.split(' ', 2)

    if message.include?('Merge pull request')
      # マージコミットの場合は、マージ元ブランチを取得
      merge_info = `git log -1 --pretty=format:"%P" #{hash}`.split(' ')
      parent_commit = merge_info[1] # 2番目の親コミットがマージ元
      merge_branch = `git name-rev --name-only #{parent_commit}`.strip
      { hash:, message:, branch: merge_branch }
    else
      { hash:, message:, branch: }
    end
  end
end
