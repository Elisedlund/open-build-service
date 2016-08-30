class AutoLockAttribute < ActiveRecord::Migration

  class AttribTypeModifiableBy < ActiveRecord::Base; end

  def self.up
    role = Role.find_by_title("maintainer")
    ans = AttribNamespace.find_by_name "OBS"

    AttribTypeModifiableBy.reset_column_information

    at = AttribType.create(:attrib_namespace => ans, :name => "AutoLock", :value_count => 0,
      :description => "Mark this project to be locked automatically after inactivity period.")
    AttribTypeModifiableBy.create(role_id: role.id, attrib_type_id: at.id)

    add_column :configurations, :autolock_after_days, :integer
  end

 def self.down
   AttribType.find_by_namespace_and_name("OBS", "AutoLock").delete()
   remove_column :configurations, :autolock_after_days
 end

end

