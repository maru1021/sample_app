class SlackNotifier
  def initialize
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end
    @client = Slack::Web::Client.new
  end

  def send_message(channel, message)
    @client.chat_postMessage(channel:, text: message, as_user: true)
  end
end
