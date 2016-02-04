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
    letsencrypt_installed("mydomain.com",["mydomain.com", "alt1.mydomain.com","alt2.mydomain.com"], <option> True)  # last optional boolean param: can be staging certs? ;returns true/false
    letsencrypt_installed(["mydomain.com", "alt1.mydomain.com","alt2.mydomain.com"], <option> True)  # uses the first item in array as cert dirname, last optional boolean param: can be staging certs? ; returns true/false
    EOS
  ) do |args|
        result = false
        canbestaging = false
        if args.size == 1
            raise(Puppet::ParseError, "letsencrypt_installed(): If 1 argument it must be an Array") unless args[0].is_a? (Array)
            aliasdomains = args[0]
            vhost = aliasdomains[0]
        elsif args.size == 2 and args[1].is_a? (Boolean)
            raise(Puppet::ParseError, "letsencrypt_installed(): If 1 argument it must be an Array") unless args[0].is_a? (Array)
            aliasdomains = args[0]
            vhost = aliasdomains[0]
            canbestaging = args[1]
        elsif args.size == 2
            raise(Puppet::ParseError, "letsencrypt_installed(): First argument must be a String") unless args[0].is_a? (String)
            raise(Puppet::ParseError, "letsencrypt_installed(): Second argument must be an Array") unless args[1].is_a? (Array)
    	    vhost = args[0]
    	    aliasdomains = args[1]
        elsif args.size == 3
            raise(Puppet::ParseError, "letsencrypt_installed(): First argument must be a String") unless args[0].is_a? (String)
            raise(Puppet::ParseError, "letsencrypt_installed(): Second argument must be an Array") unless args[1].is_a? (Array)
            raise(Puppet::ParseError, "letsencrypt_installed(): Last argument must be a Boolean") unless args[2].is_a? (Boolean)
            vhost = args[0]
            aliasdomains = args[1]
            canbestaging = args[2]
    	else
            raise(Puppet::ParseError, "letsencrypt_installed(): Wrong number of arguments given (#{args.size} for 1 or 2 with optional extra boolean param)")
        end

    	installed = lookupvar('letsencrypt_installed_domains')
        raise(Puppet::ParseError, "letsencrypt_installed_domains: this fact must be a Hash. Be sure to setup 'stringify_facts = false' in [main] section of puppet configs") unless installed.is_a? (Hash)
    	vhosttested = installed[vhost]

        unless vhosttested.nil? and vhosttested['domains'].nil? and vhosttested['domains'].size > 0
            if !canbestaging and vhosttested['domains'] == "staging"
                return false
            end
        	vhostactive = vhosttested['domains'] & aliasdomains
            #raise(Puppet::ParseError, "vhostactive="+vhostactive.join(",")+" // aliasdomains="+aliasdomains.join(',') )
        	if vhostactive.size == aliasdomains.size
        		return true
        	end
        end
        return false
    end
end