class ssh {
  case $operatingsystem {
    default: {
      # ssh �ѥå����������󥹥ȡ��뤵��Ƥ��뤳�Ȥ��ݾ�
      package { 'ssh':
        ensure => installed
      }
    }
  }
}