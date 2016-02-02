#
# Function: letsencrypt_installed()
#
# Checks SSL cetificate installed.
#
# Returns false if the certificate is not installed by letsencrypt.
#
# Parameter: servername // vhost filename
#
module Puppet::Parser::Functions
    newfunction(:letsencrypt_installed, :type => :rvalue, :doc => <<-EOS
This function checks if the provided vhost has valid SSL certificate installed.
*Examples:*
    letsencrypt_installed("mydomain.com",["mydomain.com", "alt1.mydomain.com","alt2.mydomain.com"])  # returns true/false
    EOS
  ) do |args|

    	raise(Puppet::ParseError, "letsencrypt_installed(): Wrong number of arguments given (#{arguments.size} for 2)") if args.size != 2
    	vhost = args[0]
    	aliasdomains = args[1]
    	result = false

    	raise(Puppet::ParseError, "letsencrypt_installed(): First argument must be a String") unless vhost.is_a? (String)
    	raise(Puppet::ParseError, "letsencrypt_installed(): Second argument must be an Array") unless aliasdomains.is_a? (Array)

    	installed = lookupvar('letsencrypt_installed_domains')
        raise(Puppet::ParseError, "letsencrypt_installed_domains: this fact must be a Hash. Be sure to setup 'stringify_facts = false' in [main] section of puppet configs") unless installed.is_a? (Hash)
    	vhosttested = installed[vhost]

        unless vhosttested.nil?
        	vhostincluded = vhosttested & aliasdomains
        	if vhostincluded.size == installed[vhost].size
        		return true
        	end
        end
        return false
    end
end