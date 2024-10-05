class GitClient
  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def self.latest_tag
    `git describe --tags --abbrev=0`.strip
  end

  def self.commits_since_latest_tag(branch)
    latest_tag = self.latest_tag

    if latest_tag.empty?
      `git log #{branch} --pretty=format:"%H %s" -n 10`.split("\n")
    else
      `git log #{latest_tag}..#{branch} --pretty=format:"%H %s"`.split("\n")
    end
  end
end
