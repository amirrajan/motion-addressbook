require "motion-addressbook/version"

lib_dir_path = File.dirname(File.expand_path(__FILE__))
project_path = File.join(lib_dir_path, "../motion/address_book")

def globbed_files(root, path)
  Dir.glob(File.join(root, path))
end

Motion::Project::App.setup do |app|
  app.files.unshift(File.join(lib_dir_path, "../motion/address_book.rb"))
  app.files.unshift(globbed_files(project_path, "/common/**/*.rb"))

  # Added as weak in case the app.deployment_target < 9
  app.weak_frameworks += ['Contacts', 'ContactsUI']
  app.files.unshift(globbed_files(project_path, "/cn/**/*.rb"))

  app.frameworks += ['AddressBook', 'AddressBookUI']
  app.files.unshift(globbed_files(project_path, "/ab/**/*.rb"))
end
