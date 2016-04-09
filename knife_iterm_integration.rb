require 'json'
require 'optparse'

options = {:chefserver => nil, :user => nil}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: knife_iterm_b.rb [options]"
	opts.on('-s', '--chefserver chefserver', 'Chefserver') do |chefserver|
		options[:chefserver] = chefserver;
	end
	opts.on('-u', '--user user', 'User') do |user|
		options[:user] = user;
	end
	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

if options[:chefserver] == nil
	print 'Enter Project/Environment/Domain Name as appropriate: '
    options[:chefserver] = gets.chomp
end

if options[:user] == nil
	print 'Enter User ID (the one you use to login to the nodes): '
    options[:user] = gets.chomp
end

roles = `knife role list`.split("\n")

nodes_roles = {}
roles.each { |role|
	nodes_roles[:"#{role}"] = `knife search node "role:#{role}" -i`.split("\n")
	puts "for role #{role}, the nodes are"
	puts nodes_roles[:"#{role}"]
}

profiles = []

nodes_roles.each { |key,values|
	if !values.empty?
		puts "role #{key} has #{values} nodes"
		values.each { |value|
			element = {}
			element[:Name] = "#{value}"
			element[:Guid] = "#{key} - #{value}"
			element[:"Custom Command"] = "Yes"
			element[:Command] = "ssh #{options[:user]}@#{value}"
			element[:Tags] = ["#{options[:chefserver]}/#{key}"]
			
			profiles.push(JSON.load(element.to_json))
			puts element.to_json
		}
	end	
}

puts profiles
the_file_content = {}
the_file_content[:Profiles] = profiles
the_file = File.open("#{options[:chefserver]}_#{options[:user]}.json","w")
the_file.write(JSON.pretty_generate(the_file_content))
