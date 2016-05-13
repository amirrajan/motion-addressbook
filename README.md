# Addressbook for RubyMotion

[![Gem Version][gem-version-image]][gem-version-link]
[![Dependencies Status][dependencies-image]][dependencies-link]
[![Build Status][build-status-image]][build-status-link]
[![Code Climate][code-climate-image]][code-climate-link]

A RubyMotion wrapper around the iOS and OSX Address Book frameworks for
RubyMotion apps.

Apple's Address Book Programming Guide for [iOS][ios-docs-link]
or for [OSX][mac-docs-link]

## Requirements

* RubyMotion >= 2.8
* iOS 6-9

## Installation

### Bundler (recommended)

Add it to your Gemfile:

```ruby
gem 'motion-addressbook'
```

Ensure you have these lines to your `Rakefile`:

```ruby
require 'bundler'
Bundler.require
```

### Manual install

```bash
$ gem install motion-addressbook
```

## Usage

### Requesting access

1 - Let the gem take care of it for you

```ruby
AddressBook.contacts
```

This will request authorization if it has not yet been requested, and raise if
it has already been requested and was denied.

2 - Manually decide when to ask the user for authorization

```ruby
# Disable auto-connection before calling anything else, otherwise the gem will
# automatically request authorization if it has not already been requested
AddressBook.auto_connect = false

# Do some other stuff (maybe wait for the right screen)

# Automatically connect if we're authorized, otherwise request authorization
AddressBook.connect
```

3 - Manually decide when to ask and whether to wait for a response

```ruby
# To take full control whether we are already authorized
if AddressBook.authorized?
  puts "This app is authorized!"
  if AddressBook.connected?
    puts "We already have access to the address book"
  else
    puts "We need to manually connect"
    AddressBook.connect
  end
else
  puts "This app is not authorized!"
end

# ask the user to authorize us (blocking)
if AddressBook.request_authorization
  # do something now that the user has said "yes"
else
  # do something now that the user has said "no"
end

# ask the user to authorize us (asynchronously)
AddressBook.request_authorization do |granted|
  # this block is invoked sometime later
  if granted
    Dispatch::Queue.main.sync do
      # do something now that the user has said "yes"
      # This has to be done on the main thread.
    end
  else
    # do something now that the user has said "no"
  end
end
# do something here before the user has decided
```

The iOS6 simulator does not demand AddressBook authorization. The iOS7 simulator
does.

### UI -- NEEDS WORK (and untested)

#### Showing the ABPeoplePickerNavigationController

```ruby
AddressBook::AB::UI::Picker(AddressBook.instance) do |person|
  if person
    # person is an AddressBook::Person object
  else
    # canceled
  end
end
```

You can also specify the presenting controller:

```ruby
AddressBook.pick presenter: self do |person|
  ...
end
```

#### Showing the ABNewPersonViewController

```ruby
AddressBook.create do |person|
  if person
    # person is an AddressBook::Person object
  else
    # canceled
  end
end
```

### Working with Person objects

Get a list of existing people from the Address Book. On IOS, results are sorted
using the sort order (First/Last or Last/First) chosen by the user in iOS
Settings.

```ruby
AddressBook.people # Aliased to AddressBook.contacts
=> [#<AddressBook::Person:3: {:first_name=>"John", :last_name=>"Appleseed", ...}>, ...]
```

Create a new Person and save to the Address Book.

Note that Person records can take multiple values for email addresses, phone
numbers, postal address, social profiles, and instant messaging
profiles.

```ruby
AddressBook.person_create(
  first_name: 'Alex',
  last_name: 'Rothenberg',
  emails: [{ label: 'Home', value: 'alex@example.com' }],
  phones: [{ label: 'Mobile', value: '9920149993' }]
)
=> #<AddressBook::Person:7: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>
```

Construct a new Person but do not store it immediately in the Address Book.

```ruby
bob = AddressBook.person_new(first_name: 'Bob')
=> #<AddressBook::Person:-1: {:first_name=>"Bob"}>
bob.last_name = 'Brown'
bob.save
=> #<AddressBook::Person:9: {:first_name=>"Bob", :last_name=>"Brown"}>
```

```ruby
AddressBook.person_where(email: 'alex@example.com')
=> [#<AddressBook::Person:14: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>]
```

### Update existing Person

```ruby
alex = AddressBook.person_where(email: 'alex@example.com')
alex.job_title = 'RubyMotion Developer'
alex.save
```

<!--
Or to alter all the attributes at once (preserve the record identifier
but change some or all of the values):

```ruby
alex = AddressBook.person_where(email: 'alex@example.com')
alex.replace({:first_name=>"Alex", :last_name=>"Rider", ...})
alex.save
```
-->

### Contact Groups

```ruby
AddressBook.groups
=> [#<AddressBook::Group:1:Friends: 1 members>, #<AddressBook::Group:2:Work: 0 members>]

group = AddressBook.groups.first
group.members
=> [#<AddressBook::Person:2: {:first_name=>"Daniel", :last_name=>"Higgins", ...}>]
```

### Notifications (\* iOS only \*)

The iOS Address Book does not deliver notifications of changes through the
standard Notification Center. `motion-addressbook` wraps the framework
`ABAddressBookRegisterExternalChangeCallback` call with an optional handler that
converts the update event to an iOS notification.

```ruby
AddressBook.observe!

callback = Proc.new { |notification| NSLog "Address Book was changed!" }
NSNotificationCenter.defaultCenter.addObserverForName(:addressbook_updated,
  object: nil,
  queue: NSOperationQueue.mainQueue,
  usingBlock: callback
)

# Or if you're using BubbleWrap:
App.notification_center.observe(:addressbook_updated) do |notification|
  NSLog "Address Book was changed!"
end
```

The notification must be explicitly enabled in your application. In some cases
iOS appears to trigger multiple notifications for the same change event, and if
you are doing many changes at once you will receive a long stream of
notifications.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[build-status-link]: https://travis-ci.org/jbender/motion-addressbook
[build-status-image]: https://img.shields.io/travis/jbender/motion-addressbook/master.svg?maxAge=2592000
[code-climate-link]: https://codeclimate.com/github/jbender/motion-addressbook
[code-climate-image]: https://img.shields.io/codeclimate/github/jbender/motion-addressbook.svg?maxAge=2592000
[gem-version-link]: https://rubygems.org/gems/motion-addressbook
[gem-version-image]: https://img.shields.io/gem/v/motion-addressbook.svg?maxAge=2592000
[dependencies-link]: https://gemnasium.com/github.com/jbender/motion-addressbook
[dependencies-image]: https://img.shields.io/gemnasium/jbender/motion-addressbook.svg?maxAge=2592000
[ios-docs-link]: https://developer.apple.com/library/ios/documentation/AddressBook/Reference/AddressBook_iPhoneOS_Framework/index.html#//apple_ref/doc/uid/TP40007212
[mac-docs-link]: https://developer.apple.com/library/mac/documentation/UserExperience/Reference/AddressBook/ObjC_classic/index.html#//apple_ref/doc/uid/20001692
