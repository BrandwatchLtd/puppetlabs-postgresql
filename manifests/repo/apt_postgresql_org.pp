# PRIVATE CLASS: do not use directly
class postgresql::repo::apt_postgresql_org inherits postgresql::repo {
  include ::apt

  # Here we accurately replicated the instructions on the PostgreSQL site:
  #
  # http://www.postgresql.org/download/linux/debian/
  #
  # using http protocol for apt and https for getting the key looks intentional as per
  # https://www.postgresql.org/message-id/YTn/LRZEtVi38f5G%40msg.df7cb.de
  #
  $default_baseurl = 'http://apt.postgresql.org/pub/repos/apt/'

  if $lsbdistcodename == 'stretch' {
    $_baseurl = 'https://apt-archive.postgresql.org/pub/repos/apt'
    $repos = "main"
       } else {
    $_baseurl = pick($postgresql::repo::baseurl, $default_baseurl)
    $repos = "main ${postgresql::repo::version}"
  }

  apt::pin { 'apt_postgresql_org':
    originator => 'apt.postgresql.org',
    priority   => 500,
  }
  -> apt::source { 'apt.postgresql.org':
    location => $_baseurl,
    release  => "${::lsbdistcodename}-pgdg",
    repos    => "main ${postgresql::repo::version}",
    key      => {
      id     => 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8',
      source => 'https://www.postgresql.org/media/keys/ACCC4CF8.asc',
    },
    include  => {
      src => false,
    },
  }

  Apt::Source['apt.postgresql.org']->Package<|tag == 'postgresql'|>
  Class['Apt::Update'] -> Package<|tag == 'postgresql'|>
}
