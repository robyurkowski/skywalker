require 'skywalker/command'

class CreateGroupCommand < Skywalker::Command
  def execute!
    save_group!
    send_notifications!
  end


  def required_args
    %w(user group)
  end

  ################################################################################
  # Operations
  ################################################################################
  private def save_group!
    group.save!
  end


  private def send_notifications!
    notifier.deliver if send_user_email?
  end


  ################################################################################
  # Guards
  ################################################################################
  private def send_user_email?
    user.receives_email?
  end


  ################################################################################
  # Accessors
  ################################################################################
  private def notifier
    @notifier ||= ::NotificationsMailer.group_created_notification(group)
  end


  # def run_failure_callbacks
  #   require 'pry'; binding.pry
  # end
end
