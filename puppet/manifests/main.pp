Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

package { ["imagemagick", "curl"]:
  ensure  => present,
}

# Install apache and PHP
class { 'apache':
	mpm_module => 'prefork', # required in precise32
}
class {'apache::mod::php': }
apache::mod { 'rewrite': }

php::module { ["mysql", "gd", "mcrypt", "imagick", "curl"]:
  notify => Service["httpd"],
}

# Install mysql
class { 'mysql::server':
	override_options => {
		mysqld => {
			bind_address => '0.0.0.0'
		}
	},
	grants => {
		'root@%' => {
			ensure     => 'present',
			options    => ['GRANT'],
			privileges => ['ALL'],
			table      => '*.*',
			user       => 'root@%',
		},
	}
}

# Install composer
class custom {
	# Install composer
	exec { 'composer_install':
		command => 'curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer',
		path    => '/usr/bin:/usr/sbin',
		require => Package['curl'],
	}

	# Generate SSH key for vagrant user
	exec { "ssh_keygen-vagrant":
		command => "ssh-keygen -t rsa -f \"/home/vagrant/.ssh/id_rsa\" -N ''",
		user    => "vagrant",
		creates => "/home/vagrant/.ssh/id_rsa",
	}

}
include custom

# Include vhosts
import 'vhosts/*.pp'

################################################
# CUSTOM CONFIGURATION
################################################

class custom_config {

	# Copy vhosts files 
	exec { "copy_vhosts":
		command => "cp /vagrant/files/apache2/sites-enabled/* /etc/apache2/sites-enabled",
		path => "/usr/bin:/usr/sbin:/bin",
		notify => Service["httpd"],
	}
}

# Process the config
include custom_config
