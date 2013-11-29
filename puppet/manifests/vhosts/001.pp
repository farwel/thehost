# Instalar vhost

# Pull code from git
vcsrepo { '/var/www/vhosts/boilerplate':
    ensure => present,
    provider => git,
    source => 'git://github.com/farwel/boilerplate.git'
}

# Create database

# Configure vhost