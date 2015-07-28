default['mod_security2']['source']['revision'] = 'v2.9.0'
default['mod_security2']['source']['repo'] = 'https://github.com/SpiderLabs/ModSecurity.git'
default['mod_security2']['source']['compile_flags'] = []
default['mod_security2']['source']['packages'] =
  %w(git
     libxml2
     libxml2-dev
     libxml2-utils
     libaprutil1
     libaprutil1-dev
     autoconf
     automake
     libtool
     apache2-threaded-dev
     libcurl4-openssl-dev
     libyajl-dev
     liblua5.1-0-dev
  )

default['mod_security2']['home'] = '/opt/ModSecurity'
default['mod_security2']['platform'] = :nginx
