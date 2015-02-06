class circus::configure (
  $include_dir = '/etc/circus/conf.d',
  $logoutput   = "${::circus::log_prefix}/circus/circusd.log",
) {
  file { "${::circus::conf_prefix}/circus":
    ensure => 'directory',
    owner  => '0',
    group  => '0',
    mode   => '0755',
  }

  file { "${::circus::conf_prefix}/circus/conf.d":
    ensure => 'directory',
    owner  => '0',
    group  => '0',
    mode   => '0755',
  }

  file { "${::circus::conf_prefix}/circus/circusd.ini":
    ensure => 'file',
    owner  => '0',
    group  => '0',
    mode   => '0644',
    notify => Class['::circus::services'],
  }

  file { "${::circus::log_prefix}/circus":
    ensure => 'directory',
    owner  => '0',
    group  => '0',
    mode   => '0755',
  }

  case $::circus::service_circus_provider {
    'sysv': {
      $dest_path = '/etc/init.d/circus'
      $dest_mode = '0755'
      $extension = 'init'
    }
    'upstart': {
      $dest_path = '/etc/init/circus.conf'
      $dest_mode = '0644'
      $extension = 'upstart'
    }
    'systemd': {
      $dest_path = '/lib/systemd/system/circus.service'
      $dest_mode = '0644'
      $extension = 'service'
    }
    default: {
      fail('Unsupported init-system')
    }
  }

  file { $dest_path:
    ensure => 'file',
    source => "puppet:///modules/${module_name}/circus.${extension}",
    owner  => '0',
    group  => '0',
    mode   => $dest_mode,
    notify => Class['::circus::services'],
  }

  file { "${::circus::logrotate_dir}/circus":
    ensure => 'file',
    source => "puppet:///modules/${module_name}/circus.logrotate",
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  ::circus::setting { 'include_dir' : value => $include_dir, }
  ::circus::setting { 'logoutput'   : value => $logoutput, }

}
