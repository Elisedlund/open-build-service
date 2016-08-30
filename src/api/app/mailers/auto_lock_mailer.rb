class AutoLockMailer < ActionMailer::Base

  def set_headers
    @host = ::Configuration.first.obs_url
    @configuration = ::Configuration.first

    headers['Precedence'] = 'bulk'
    headers['X-Mailer'] = 'OBS Notification System'
    headers['X-OBS-URL'] = ActionDispatch::Http::URL.url_for(controller: :main, action: :index, only_path: false, host: @host)
    headers['Auto-Submitted'] = 'auto-generated'
    headers['Return-Path'] = mail_sender
    headers['Sender'] = mail_sender
  end

  def mail_sender
    'OBS Notification <' + ::Configuration.first.admin_email + '>'
  end

  def send_notification(proj)
    return if proj.nil?
    @project = proj

    set_headers

    emails = ""
    @project.relationships.where(role: Role.rolecache['maintainer']).pluck(:user_id, :group_id).each do |usr, group|
      unless group.nil?
        GroupsUser.where(group: group).pluck(:user_id, :email).each do |user_id, send_mail|
          email = send_mail ? User.find(user_id).email.to_s : ""
          emails += "#{email}; " unless email.empty? or emails.include? email
        end
      end
      unless usr.nil?
        email = User.find(usr).email.to_s
        emails += "#{email}; " unless email.empty? or emails.include? email
      end
    end
    return if emails.empty?

    mail(to: emails,
      subject: "Project #{@project.name} is locked",
      from: mail_sender,
      template_name: 'auto_lock')
  end

end

