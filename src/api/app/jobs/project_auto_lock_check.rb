
class ProjectAutoLockCheck

  def perform
    # autolock needs to be enabled in configurations
    autolockDays = ::Configuration.first.autolock_after_days
    return unless autolockDays and autolockDays > 0

    # inactivity period when project will locked
    @autolock_ts = autolockDays.days

    User.current ||= User.find_by_login "Admin"
    lock_attribute = AttribType.find_by_namespace_and_name("OBS", "AutoLock")

    Project.find_by_attribute_type(lock_attribute).each do |proj|
      autolock_project proj unless proj.is_locked?
    end
  end

  def autolock_project(proj)
      # find the latest change done in project
      latest_update_ts = proj.updated_at.to_i
      Package.where(project_id: proj.id).pluck(:name, :updated_at).each do |pkg, date|
        date_ts = date.to_i
        if date_ts > latest_update_ts
          latest_update_ts = date_ts
        end
      end
      current_ts = Time.now.to_i
      if latest_update_ts + @autolock_ts < current_ts
        # project has been inactive too long, lock it
        proj.flags.create(:status => 'enable', :flag => 'lock')
        proj.store
        # notify project maintainers
        AutoLockMailer.send_notification(proj).deliver
      end
  end

end

