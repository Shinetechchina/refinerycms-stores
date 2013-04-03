require 'highline/import'

# see last line where we create an admin if there is none, asking for email and password
def prompt_for_admin_password
  if ENV['ADMIN_PASSWORD']
    password = ENV['ADMIN_PASSWORD'].dup
    say "Admin Password #{password}"
  else
    password = ask('Password [spree123]: ') do |q|
      q.echo = false
      q.validate = /^(|.{5,40})$/
      q.responses[:not_valid] = 'Invalid password. Must be at least 5 characters long.'
      q.whitespace = :strip
    end
    password = 'spree123' if password.blank?
  end

  password
end

def prompt_for_admin_email
  if ENV['ADMIN_EMAIL']
    email = ENV['ADMIN_EMAIL'].dup
    say "Admin User #{email}"
  else
    email = ask('Email [spree@example.com]: ') do |q|
      q.echo = true
      q.whitespace = :strip
    end
    email = 'spree@example.com' if email.blank?
  end

  email
end

def prompt_for_admin_username
  if ENV['ADMIN_USERNAME']
    username = ENV['ADMIN_USERNAME'].dup
    say "Admin User #{username}"
  else
    username = ask('Username [admin]: ') do |q|
      q.echo = true
      q.whitespace = :strip
    end
    username = 'admin' if username.blank?
  end

  username
end

def create_admin_user
  if ENV['AUTO_ACCEPT']
    password = 'spree123'
    email = 'spree@example.com'
    username = 'admin'
  else
    puts 'Create the admin user (press enter for defaults).'
    email = prompt_for_admin_email
    username = prompt_for_admin_username
    password = prompt_for_admin_password
  end
  attributes = {
    :password => password,
    :password_confirmation => password,
    :email => email,
    :username => username,
    :login => email
  }

  require 'refinerycms'
  require 'spree/core'

  if Refinery::User.find_by_email(email)
    say "\nWARNING: There is already a user with the email: #{email}, so no account changes were made.  If you wish to create an additional admin user, please run rake spree_auth:admin:create again with a different email.\n\n"
  else
    admin = Refinery::User.new(attributes)
    if admin.save
      role = Spree::Role.find_or_create_by_name 'admin'
      admin.spree_roles << role

      admin.add_role(:refinery)
      # add superuser role if there are no other users
      admin.add_role(:superuser)
      # add plugins
      admin.plugins = Refinery::Plugins.registered.in_menu.names

      admin.save
      say "Done!"
    else
      say "There was some problems with persisting new admin user:"
      admin.errors.full_messages.each do |error|
        say error
      end
    end
  end
end

if Refinery::User.count.zero?
  create_admin_user
else
  puts 'Admin user has already been previously created.'
  if agree('Would you like to create a new admin user? (yes/no)')
    create_admin_user
  else
    puts 'No admin user created.'
  end
end
