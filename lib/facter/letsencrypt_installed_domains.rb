#
# Function: letsencrypt_installed_domains()
#
# Checks SSL cetificate installed.
Facter.add(:letsencrypt_installed_domains) do
    setcode do
        letsencrypt_installed_domains = {}
        Dir.glob('/etc/letsencrypt/live/*/fullchain.pem') do |pem_file|
        	require "time"

        	#vhost = `openssl x509 -noout -subject -in #{pem_file}`.downcase.gsub("\n", '').gsub("subject= /cn=", '')
            # vhost is the name of the parent cert folder.
            vhost = pem_file.downcase.gsub(/.*\/live\/(.+?)\/fullchain.*/, '\1')
        	dates = `openssl x509 -dates -noout < #{pem_file}`.gsub("\n", '')
        	raise "No date found in certificate" unless dates.match(/not(Before|After)=/)
        	certbegin = Time.parse(dates.gsub(/.*notBefore=(.+? GMT).*/, '\1'))
	        certend   = Time.parse(dates.gsub(/.*notAfter=(.+? GMT).*/, '\1'))
	        now       = Time.now

            letsencrypt_installed_domains[vhost] = []
	        if (now > certend)
	            # certificate is expired
	        elsif (now < certbegin)
	            # certificate is not yet valid
	        elsif (certend <= certbegin)
	            # certificate will never be valid
	        else
	            # certificate is still valid
                installed_domains = `openssl x509 -noout -text -in #{pem_file} | awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | tr -d "DNS:"`.gsub("\n", '').downcase
                letsencrypt_installed_domains[vhost] = installed_domains.split(',')
	        end
        end
        letsencrypt_installed_domains
    end
end
