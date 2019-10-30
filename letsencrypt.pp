# Class: ucthep::letsencrypt
#
# installs a letsencrypt certificate
#
# Parameters:
#   (none)
#
# Actions:
#   -
#
# Requires:
#   -
#
# Sample Usage:
#
class ucthep::letsencrypt
{
    if ($facts['os']['family']=='RedHat' and
         $facts['os']['release']['major']=='7'){

         class { '::letsencrypt':
            config => {
                email => 'thomas.dietel@uct.ac.za',
            },
            install_method => 'vcs',
            manage_dependencies => false,
        }
      }else {
        class { '::letsencrypt':
            config => {
                email => 'thomas.dietel@uct.ac.za',
            },
        }

    }

         package {('certbot'):
            ensure   => 'latest',
            provider => 'yum'}

         exec {"certutil":
            path  => [~/nss/httpd-csr.der],
            command => "certutil -R -d /etc/httpd/alias/ -k Server-Cert -f /etc/httpd/alias/pwdfile.txt -s "CN=$(hostname -f)" --extSAN "dns:$(hostname -f)" -o " ~/nss/httpd-csr.der"","
            }

         exec {"filename to read a certificate":
            command => 'openssl x509  -in httpd-csr.der -text,
              }
         exec {"encoding the certificate":
              command => openssl x509  -inform DER -in httpd-csr.der -text,
              }
         exec{"prevents output txt":
             command => openssl req -noout -text -inform DER -in httpd-csr.der',
             }

        letsencrypt::certonly { $fqdn:
            manage_cron          => true,
            plugin               => 'standalone',
            additional_args      => ['--preferred-challenges http'],
          }


    if [ "${1:-renew}" != "--first-time" ]
        then {
        	command => "certutil -d /etc/httpd/alias/ -V -u V -n Server-Cert -b "$(date '+%y%m%d%H%M%S%z' --date='2 days')" && exit 0",

        exec {"cleanup":
            path => [~/nss/*],
            command => 'rm -f '$WORKDIR"/*.pem,
            }
        exec {"cleanup":
            command => rm -f $WORKDIR"/httpd-csr.*'
            }

        exec {"certutil":
               path  => '[~/nss/httpd-csr.der]',
               command => "certutil -R -d /etc/httpd/alias/ -k Server-Cert -f /etc/httpd/alias/pwdfile.txt -s "CN=$(hostname -f)" --extSAN "dns:$(hostname -f)" -o " ~/nss/httpd-csr.der","
               }

        exec {"filename to read a certificate":
               command => 'openssl x509  -in httpd-csr.der -text,
                 }
        exec {"encoding the certificate":
                 command => openssl x509  -inform DER -in httpd-csr.der -text,
                 }
        exec {"prevents output txt":
                command => openssl req -noout -text -inform DER -in httpd-csr.der',
                }

       exec {"stop httpd":
          command => "service httpd stop",
          }

      exec {"certutil":
             path  => [~/nss/httpd-csr.der],
             command => "certutil -R -d /etc/httpd/alias/ -k Server-Cert -f /etc/httpd/alias/pwdfile.txt -s "CN=$(hostname -f)" --extSAN "dns:$(hostname -f)" -o " ~/nss/httpd-csr.der"","
             }

      exec { "filename to read a certificate":
             command => 'openssl x509  -in httpd-csr.der -text,
               }
      exec { "encoding the certificate":
               command => openssl x509  -inform DER -in httpd-csr.der -text,
               }
      exec{ "prevents output txt":
              command => openssl req -noout -text -inform DER -in httpd-csr.der',
              }

      letsencrypt::certonly { $fqdn:
             manage_cron          => true,
             plugin               => 'standalone',
             additional_args      => ['--preferred-challenges http'],
           }
      exec {"Removing old cert":
            command => "certutil -D -d /etc/httpd/alias/ -n Server-Cert",
           }
      exec {"Adding new cert":
           command => "certutil -A -d /etc/httpd/alias/ -n Server-Cert -t u,u,u -a -i "$WORKDIR/0000_cert.pem"",
          }
      exec {"stop httpd":
                 command => "service httpd start",
           }
  }




  firewall { '100: Allow inbound HTTP (for certbot)':
        dport    => 80,
        proto    => tcp,
        action   => accept,
        }
  group { 'nsscert':
        ensure => present,
        forcelocal => true,
        system => true,
        }
  file { [ '/nss'] :
       group => 'nsscert',
       mode => 'g+X',
       recurse => true,
   }
}
