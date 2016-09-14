require_relative '../test_helper'

class AutoLockMailerTest < ActionMailer::TestCase
  fixtures :all

  test "autolock mail" do
    prj = Project.find_by_name('autolock')

    mail = AutoLockMailer.send_notification(prj)

    assert_equal "Project #{prj.name} is locked", mail.subject
    assert_equal ["fred@feuerstein.de", "adrian@example.com"], mail.to
    assert_equal ["obs-email@opensuse.org"], mail.from
    assert_equal read_fixture('auto_lock_mail_html_part').join, mail.html_part.body.raw_source
    assert_equal read_fixture('auto_lock_mail_text_part').join, mail.text_part.body.to_s
  end

end

