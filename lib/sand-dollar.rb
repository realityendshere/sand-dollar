require 'active_support/inflector'

Gem.find_files("sand-dollar/resources/**/*.rb").each { |path| require path }
Gem.find_files("sand-dollar/models/**/*.rb").each { |path| require path }
Gem.find_files("sand-dollar/controllers/**/*.rb").each { |path| require path }
Gem.find_files("sand-dollar/authenticators/**/*.rb").each { |path| require path }

require 'sand-dollar/exceptions'
require 'sand-dollar/configuration'
require 'sand-dollar/authentication_service'
require 'sand-dollar/authenticators'
