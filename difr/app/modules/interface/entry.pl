
if($g->{msg} ne ''){print "$g->{msg}";}
else{print $g->{CGI}->h3("Welcome to $g->{sitename}");}

# this is the page where any messages may show up...
#
print "<script>window.location='$g->{scriptname}?chmod=interface_preferences'</script>";
#
# let's test that theory with this...
#
#

