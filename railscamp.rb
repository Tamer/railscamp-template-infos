#Template


#################################
#Gems
#################################
gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'rubyist-aasm'
gem 'RedCloth', :lib => 'redcloth'
gem 'haml'
gem 'paperclip'
gem 'rmagick'
gem 'braid'

#################################
#Plugins
#################################

git :init #Für Submodules


#Coding
plugin 'resource_controller', :git => 'git://github.com/giraffesoft/resource_controller.git', :submodule => true

#Testing
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'

#User Authentication
plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git', :submodule => true
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true

#Features
plugin 'acts_as_taggable_on_steroids', :git => 'git://github.com/mattetti/acts_as_taggable_on_steroids.git', :submodule => true if yes?("Want Tags ?")

submodule = yes? "Load submodules?"

plugin 'acts_as_commentable', :git => 'git://github.com/jackdempsey/acts_as_commentable.git', :submodule => submodule if yes?("Want Comments ?")
#TODO deploy.rb submodule init ausführen
git :submodule => "init" if submodule

run "braid add -p git://github.com/jackdempsey/acts_as_commentable.git" unless submodule

#################################
#Initialisers
#################################

initializer 'userauthentication.rb', <<-END
  
  #UserAuthenication
  config.active_record.observers = :user_observer
END

initializer 'mailer.rb', <<-END
  
  ActionMailer::Base.delivery_method = :smtp 
  ActionMailer::Base.default_charset = "utf-8"
  ActionMailer::Base.raise_delivery_errors = true


  ActionMailer::Base.smtp_settings = {
     :address => "", 
     :port => 25, 
     :domain => "",
     :authentication => :login,
     :user_name => "",
     :password => ""
  }
END

#Problems using #{variables}
# --> use seperate file
# --> escape em

initializer 'fielderrorproc.rb', <<-END
  
 ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
   if html_tag =~ /<(input)[^>]+type=["'](hidden)/
     html_tag
   else

   msg = instance.error_message
   #title = msg.kind_of?(Array) ? '* ' + msg.join("\n* ") : msg
   title = msg.kind_of?(Array) ? '' + msg.join("<br/> ") : msg
   "\#{html_tag} <div class=\"fieldWithErrors\" title=\"\">\#{title}</div>" 
   end
 end
END


initializer 'will-paginate.rb', <<-END
 require "will_paginate"
 WillPaginate::ViewHelpers.pagination_options[:renderer] = 'PaginationListLinkRenderer'
END


lib 'pagination_list_link_renderer.rb',<<-CODE
class PaginationListLinkRenderer < WillPaginate::LinkRenderer

  def to_html
    links = @options[:page_links] ? windowed_links : []

    @options[:previous_label] = "< Zurück"
    @options[:next_label] = "Weiter >"
    links.unshift(page_link_or_span(@collection.previous_page, 'previous', @options[:previous_label]))
    links.push(page_link_or_span(@collection.next_page, 'next', @options[:next_label]))

    html = links.join(@options[:separator])
    @options[:container] ? @template.content_tag(:ul, html, html_attributes) : html
    
  end
end
CODE


#Default Layout

file 'app/layouts/application.html.erb', <<- CODE
<html>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
</html>
CODE

#dynamic creation of migration files?
file "db/migrate/1_initial_migration.rb",<<-END
%q{class InitialMigration < ActiveRecord::Migration

  def self.up
    create_table "" do |t|
  end

  def self.down
    drop_table :
  end
  
end
}
END


#Rakefiles

#################################
#Generates
#################################
generate("authenticated", "user sessions --include-activation --stateful --rspec")
generate("rspec")
generate("roles", "Role User")
generate("acts_as_taggable_migration")
  
#################################
#Run
#################################
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"

run "rm public/rails.png"
run "rm public/javascript/*" #Kein Prototype

#################################
#Rake
#################################
rake "gems:install"
rake "db:migrate"

#################################
#Routes
#################################
route "map.signup  '/signup', :controller => 'users',   :action => 'new'"
route "map.login  '/login',  :controller => 'session', :action => 'new'"
route "map.logout '/logout', :controller => 'session', :action => 'destroy'"
route "map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil"
route "map.resources :users, :member => { :suspend   => :put, :unsuspend => :put, :purge => :delete }"

#Inside

#################################
#Git
#################################
git :submodule => "init" if submodule
git :add => '.'
git :commit => "-a -m 'Initial commit'"

  
puts "Love your app!"
