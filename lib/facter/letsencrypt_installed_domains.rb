#
# Function: letsencrypt_installed_domains()
#
# Checks SSL cetificate installed.
Facter.add(:letsencrypt_installed_domains) do
    setcode do
        letsencrypt_installed_domains = {}
        Dir.glob('/etc/letsencrypt/live/*/fullchain.pem') do |pem_file|
        	require "time"

        	vhost = `openssl x509 -noout -subject -in #{pem_file}`.gsub("Subject: CN=", '')
        	dates = `openssl x509 -dates -noout < #{pem_file}`.gsub("\n", '')
        	raise "No date found in certificate" unless dates.match(/not(Before|After)=/)
        	certbegin = Time.parse(dates.gsub(/.*notBefore=(.+? GMT).*/, '\1'))
	        certend   = Time.parse(dates.gsub(/.*notAfter=(.+? GMT).*/, '\1'))
	        now       = Time.now

	        if (now > certend)
	            # certificate is expired
	        elsif (now < certbegin)
	            # certificate is not yet valid
	        elsif (certend <= certbegin)
	            # certificate will never be valid
	        else
	            # return number of seconds certificate is still valid for
          		letsencrypt_installed_domains[vhost] = `openssl x509 -noout -text -in #{pem_file} | awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | tr -d "DNS:"`.gsub("\n", '').split(',')
	        end
        end
        letsencrypt_installed_domains
    end
end
