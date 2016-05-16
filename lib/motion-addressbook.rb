require "motion-addressbook/version"

lib_dir_path = File.dirname(File.expand_path(__FILE__))
project_path = File.join(lib_dir_path, "../motion/address_book")

Motion::Project::App.setup do |app|
  app.files.unshift(Dir.glob(File.join(lib_dir_path, "../motion/address_book.rb")))

  if app.respond_to?(:template) && app.template == :osx
    # We have an OS X project
    app.frameworks += ['AddressBook']
    app.files.unshift(Dir.glob(File.join(project_path, "/osx/**.rb")))
  else
    # We have an iOS project
    # Added as weak in case the app.deployment_target < 9
    app.weak_frameworks += ['Contacts', 'ContactsUI']
    app.files.unshift(Dir.glob(File.join(project_path, "/cn/**/*.rb")))

    app.frameworks += ['AddressBook', 'AddressBookUI']
    app.files.unshift(Dir.glob(File.join(project_path, "/ab/**/*.rb")))
  end
end
