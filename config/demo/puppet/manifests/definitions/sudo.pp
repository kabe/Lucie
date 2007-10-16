class sudo {
  case $operatingsystem {
    default: {
      # sudo �p�b�P�[�W���C���X�g�[������Ă��邱�Ƃ�ۏ�
      package { 'sudo':
        ensure => installed
      }
    }
  }

  # /etc/sudoers �� puppet/files/sudoers ����R�s�[���A�K�؂ȃp�[�~�b�V������ݒ�
  file { 'sudoers':
    path => $operatingsystem ? {
      default => '/etc/sudoers'
    },
    source => 'puppet://lucie-server.localdomain.com/files/sudoers',
    mode => 0440,
    owner => root,
    group => $operatingsystem ? {
      default => root
    }
  }
}
