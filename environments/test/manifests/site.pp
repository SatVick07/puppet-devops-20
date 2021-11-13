node "test-site" {
  $dir_str = [ "/var/www/test-app", "/var/www/test-app/current", "/var/www/test-app/releases", "/var/www/test-app/shared"]
  file { $dir_str:
    ensure => 'directory',
    owner   => root,
    group   => root,
    mode    => '755'
  }

  file {'/var/www/test-app/current/index.html':
    ensure => 'file',
    content => 'This is a sample app.',
    owner   => root,
    group   => root,
    mode    => '755'
  }

  class { 'nginx':
    client_max_body_size => '512M',
    worker_processes => 2
  }

  # NGINX Configuration
  file { '/etc/nginx/ssl':
    ensure => directory,
    owner => 'root',
    group => 'root',
  }

  file { '/etc/nginx/ssl/example.com.crt':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/nginx/example.com.crt',
  }

  file { '/etc/nginx/ssl/example.com.key':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/nginx/example.com.key',
  }

  $server_name = "testapi.example.com"

  nginx::resource::server {"$server_name":
    listen_port          => 80,
    ensure               => present,
    use_default_location => false,
    maintenance          => true,
    maintenance_value    => 'return 301 https://$host$request_uri',
    www_root             => "/var/www/test-app/current/",
    access_log           => '/var/log/nginx/ssl-testapi.example.com.access.log combined',
    error_log            => '/var/log/nginx/ssl-testapi.example.com.error.log',
  }

  nginx::resource::server {'$server_name':
    ssl                  => true,
    ssl_port             => 443,
    ssl_redirect         => true,
    ssl_cert             => "/etc/nginx/ssl/example.com.crt",
    ssl_key              => "/etc/nginx/ssl/example.com.key",
    ssl_protocols        => 'TLSv1.2 TLSv1.1 TLSv1',
    ssl_ciphers          => 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS',
    ssl_cache            => 'shared:SSL:10m',
    ssl_session_timeout  => '5m',
    ensure               => present,
    use_default_location => false,
    www_root             => "/var/www/test-app/current/",
    access_log           => '/var/log/nginx/ssl-testapi.example.com.access.log combined',
    error_log            => '/var/log/nginx/ssl-testapi.example.com.error.log',
  }

  nginx::resource::location {'/':
    server               => '$server_name',
    ensure               => present,
    ssl                  => true,
    ssl_only             => false,
    www_root             => '/var/www/test-app/current/',
    priority             => 401,
  }

  nginx::resource::location {'~* ^.+\.(jpg|jpeg|gif)$':
    server               => '$server_name',
    ensure               => present,
    ssl                  => true,
    ssl_only             => true,
    expires              => '30d',
    www_root             => '/var/www/test-app/current/',
    priority             => 402,
  }

}
