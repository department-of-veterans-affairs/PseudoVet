package Alpha;
#use strict;
require Exporter;
require DBI;
use CGI qw(:all);
use CGI::Carp qw( fatalsToBrowser );
use CGI::Pretty;
use Socket;

#use Win32::TieRegistry(Delimiter=>"/",ArrayValues=>0);
use POSIX;
use vars qw(@ISA @EXPORT $Version);
@ISA=qw(Exporter);
@EXPORT=qw(
  new,
  tabs,
);
my $VERSION=1.1;

sub new{
  my $invocant=shift;
  my $class=ref($invocant) || $invocant; # object or class name
  my $self= {
    webroot => $ENV{'DOCUMENT_ROOT'},
    dbh => "unknown",
    sys_sid => "",
    sys_username => "",
    sys_vars => "",
    sys_begin => "",
    sys_expire => "",
    sys_theme => "",
    sys_firstname => "",
    sys_timeout => "",
    sys_user_ip => "",
    sys_iphash => "",
    sys_hostname => "unknown",
    sys_status => "",
    sys_mod => "login",
    @_,
  };
  $self->{sys_user_ip}=$ENV{'REMOTE_ADDR'};
  $self->{sys_iphash}=inet_aton("$self->{sys_user_ip}");
  $self->{sys_hostname}=gethostbyaddr($self->{sys_iphash},AF_INET);
  if(not defined($self->{sys_hostname})){$self->{sys_hostname}=$self->{sys_user_ip};}

  ## get all params...
  $self->{CGI}=new CGI; my @p=$self->{CGI}->param();
  foreach $var(@p){$self->{$var}=$self->{CGI}->param($var);}
  return bless $self, $class;
}


sub tabs{
  my $self=shift;
  my (@input)=@_;
  print "<ul>\n";
  foreach $action (@input){
    my($linkaction,$linktext)=split(/,/,$action); if($linktext eq ""){$linktext=$linkaction;}
    my $highlight="";
    if($self->{action} eq $linkaction){$highlight="id=\"highlight\"";}
    print "  <li $highlight onclick=\"window.location='$self->{scriptname}?action=$linkaction'\"><a href=\"$self->{scriptname}?action=$linkaction\">$linktext</a></li>\n";
  }
  print "</ul>\n";
}

1;
