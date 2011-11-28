class postfix {
  
  $relayhost     = extlookup('smtp_relay_host','')
  $relayport     = extlookup('smtp_relay_port','')
  $relayfromaddr = extlookup('smtp_relay_address','')
  $relayfrompwd  = extlookup('smtp_relay_password','')

  package { ["postfix", "libsasl2-2", "ca-certificates", "libsasl2-modules"] :
  ensure => present,
  }
  
  file { '/etc/postfix/main.cf':
      ensure => present,
      content => template('postfix/main.cf.erb'),
  }
  
  file { '/etc/postfix/sasl_passwd':
        ensure => present,
        content => template('postfix/sasl_passwd.erb'),
        mode => 400,
    }
  file { '/etc/postfix/cacert.pem' :
  ensure => present,
    source => "puppet:///postfix/Thawte_Premium_Server_CA.pem",

  }
  exec { "exec postmap" :
    command => "postmap /etc/postfix/sasl_passwd",
      require => [File["/etc/postfix/sasl_passwd"], File["/etc/postfix/main.cf"]],
  }
  service { postfix:
  ensure => running,
  subscribe => [File["/etc/postfix/main.cf"],File["/etc/postfix/sasl_passwd"]],
}
}