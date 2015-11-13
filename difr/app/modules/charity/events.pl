#!/usr/bin/perl
use HTML::Template;

# check if table exists, if not, create it
#if($g->{dbh}-> select count(*) from '$table_name' ... if it = 1 it exists...
#
# need these tables...
#
# charity_venue: id,name,description,image,website,phone,map,address_line1,address_line2,city,state,zipcode,notes
# charity_events: id,name,description,image,venue_id,time,date,phone,email,notes
# charity_event_ticket_types: id,event_id,ticket_type,ticket_title,ticket_description,ticket_price,num_tickets_total,num_tickets_available
# charity_ticket_types: id,name,description,participant_count,price
# charity_ticketholders: uid,group_name,participant_name,participant_email,participant_phone,participant_handicap,paid

# charity_groups
# uid,group_name
#print "<br /><br /><br />\n";

# must limit by role whether these items are visible
if(not defined($g->{function}) and $g->{function} eq ''){$g->{function}='sponsors';}

$g->system_menu_role_restricted("Venues"=>"venue",
                                "Sponsors"=>"sponsors",
                                "Players"=>"players",
                                "Events"=>"events",
                                "Tickets"=>"tickets");

print $g->{CGI}->span({-class=>'glyphicon glyphicon-plus', -aria-hidden=>'true'},
  $g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}&action=add"},"Add"),
);

print qq(\n<br /><br />\n);

my $function=$g->router(
  "key"=>'function',
  "default_key"=>'sponsors',
  "default_function"=>'sponsors',
  "function"=>{
    "venue"=>'venue',
    "events"=>'events',
    "tickets"=>'tickets',
    "sponsors"=>'sponsors',
    "players"=>'players',
  },
); &$function;

1; # end module

sub venue{
  my @fields=('id','name','description','image','website','phone','map','address_line1',
              'address_line2','city','state','zipcode','notes');
  my $table='charity_venues';
  my $view_fields='name,description';
  my $orderby='name';              
  my $primary_id='id';
  crud($table,$primary_id,$view_fields,$orderby,@fields);
}

sub events{  
  my @fields=('id','name','description','image','website','phone','venue_id','notes');
  my $table='charity_events';
  my $view_fields='name,description';
  my $orderby='name';
  my $primary_id='id';
  crud($table,$primary_id,$view_fields,$orderby,@fields);
}

sub tickets{
  my @fields=('id','name','description','image','event_id','venue_id','participants','price');
  my $table='charity_tickets';
  my $view_fields='name,price,description';  
  my $orderby='name';
  my $primary_id='id';  
  crud($table,$primary_id,$view_fields,$orderby,@fields);
}

sub sponsors{
  # show tickets that can have been purchased by the signed in user
  my $query="select charity_sponsors.username, charity_sponsors.name_or_group, charity_tickets.name, charity_tickets.description, charity_tickets.price
  from charity_tickets join charity_sponsors on charity_tickets.id=charity_sponsors.ticket_id
  order by charity_sponsors.username";
  # where charity_sponsors.username='$g->{sys_username}'
  
  $sth=$g->{dbh}->prepare($query); $sth->execute or die("<p>Cannot execute query: $query</p>");
  my $count=0;
  while(my($username,$name_or_group,$ticket_name,$description,$price)=$sth->fetchrow_array()){
    unless($username eq ''){
#      my $email=$g->{dbh}->selectrow_array("select email from interface_users 
#        left join charity_sponsors on interface_users.username=charity_sponsors.username");
      
      print "\n<div class='well well-sm'>\n";
      print "  <p>$username ($name_or_group) $ticket_name \$ $price\.00</p>\n";
      print "</div>\n";
      ++$count;
    }
  }
  if($count==0){
    print "\n<div class='jumbotron'>\n";
    print "  <h4>There are no purchases to view at this time.</h4>\n";
    print "</div>\n";
  }
}

sub players{
  # show list of players by name_of_group
  my $query="select name_or_group,name,email,hncp from charity_players
             order by name_or_group,name";
  $sth=$g->{dbh}->prepare($query); $sth->execute or die("<p>Cannot execute query: $query</p>");
  my $count=0;
  my $group='';
  while(my($name_or_group,$name,$email,$hncp)=$sth->fetchrow_array()){
    unless($name_or_group eq ''){
      if($group ne $name_or_group){
        $group=$name_or_group;
        print "\n<h4>$group</h4>\n";
      }
      print "\n<div class='well well-sm'>\n";
      print "  <p>$name $email HNCP: $hncp</p>\n";
      print "</div>\n";
      ++$count;
    }
  }
  if($count==0){
    print "\n<div class='jumbotron'>\n";
    print "  <h4>There are no players to view at this time.</h4>\n";
    print "</div>\n";
  }
}

# -- common routines that need to move into controller.pm

sub crud{
  my($table,$primary_id,$view_fields,$orderby,@fields)=@_;
  # care about assigned roles and actions
  #  print qq(\n<div class="container">\n);
  
  if($g->{action} ne '' and $g->{my_roles}=~m/$g->{action}/){
    # add
    if($g->{action} eq 'add'){
      if($g->{mode} eq ''){
        # build empty form
        print "    <div class=\"row\">\n";
        print "      <form action=\"$g->{scriptname}\" method=\"get\">\n";
        print "        <input type='hidden' name='function' value='$g->{function}' override>\n";
        print "        <input type='hidden' name='action' value='add'>\n";
        print "        <input type='hidden' name='mode' value='insert'>\n";
        print "        <div class=\"col-xs-6\">\n";
        foreach $field (@fields){
          if($field eq "$primary_id"){ # hidden
            # this is a new entry set to zero
            $g->{$field}=0;
            print "        <input type='hidden' name='$field' value='$g->{$field}'>\n";
          }
          else{ # not hidden
            print "        <div class=\"form-group\">\n";
            print "          <label for=\"$field\">".$g->tc($field)."</label>\n";
            print "          <input type=\"text\" class=\"form-control\" name=\"$field\" placeholder=\"".$g->tc($field)."\">\n";
            print "        </div>\n";
          }        
        }
        print "      <button type=\"submit\" class=\"btn btn-default\">Submit</button>\n";
        print "      </div>\n";
        print "    </form>\n";
        print "  </div>\n";
      }
      else{
        my $value_insert;
        foreach $field (@fields){$value_insert.="'$g->{$field}',";}
        $value_insert=~s/\,+$//; # strip last comma off the end...
        my $insert_query="insert into $table values($value_insert)";
        print "\n<!-- table: $table -->\n";
        print "\n<!-- function: $g->{function} -->\n";
        print "\n<!-- add record: $insert_query -->\n";
        $g->{dbh}->do($insert_query);
        ## send them back to default view...
        print "<script>window.location='$g->{scriptname}?function=$g->{function}'</script>\n";
      }
    }
    # edit
    if($g->{action} eq 'edit'){
      # build populated form
      # get all fields from @fields via table and primary key that was passed
      if($g->{mode} eq ''){
        # pull record from database
        # selectrow_hash
      
        # build populated form
        print "    <div class=\"row\">\n";
        print "      <form action=\"$g->{scriptname}\" method=\"get\">\n";
        print "        <input type='hidden' name='function' value='$g->{function}' override>\n";
        print "        <input type='hidden' name='action' value='add'>\n";
        print "        <input type='hidden' name='mode' value='insert'>\n";
        print "        <div class=\"col-xs-6\">\n";
        foreach $field (@fields){
          if($field eq "$primary_id"){ # hidden
            # this is a new entry set to zero
            $g->{$field}=0;
            print "        <input type='hidden' name='$field' value='$g->{$field}'>\n";
          }
          else{ # not hidden
            print "        <div class=\"form-group\">\n";
            print "          <label for=\"$field\">".$g->tc($field)."</label>\n";
            print "          <input type=\"text\" class=\"form-control\" name=\"$field\" placeholder=\"".$g->tc($field)."\">\n";
            print "        </div>\n";
          }        
        }
        print "      <button type=\"submit\" class=\"btn btn-default\">Submit</button>\n";
        print "      </div>\n";
        print "    </form>\n";
        print "  </div>\n";
      }
      else{
        # update record
      }     
    }
    # delete
    if($g->{action} eq 'delete'){
      # are you sure?
      # create form with button are you sure yes or cancel which will set validate
      my $query="select $view_fields from $table where $primary_id=$g->{$primary_id}";
      print "\n<!-- $query -->\n";
      my(@response)=$sth=$g->{dbh}->selectrow_array($query);
      # --- I am here... need to make a form that says...
      #
      # Are you sure you want to delete [values from $view_fields] ?
      # that uses validate variable...
      print "<div class='container'>\n";
      print "<h3>Are you sure you want to delete the record:</h3>\n";
      foreach $record (split(/,/,$view_fields)){
        print "  <p>$record</p>\n";
      }
      print $g->{CGI}->span({-class=>'glyphicon glyphicon-remove', -aria-hidden=>'true'},
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}&action=$g->{action}&$primary_id=$g->{$primary_id}&validate=true"},"Delete"),
      );
      print $g->{CGI}->span({-class=>'glyphicon glyphicon-ban-circle', -aria-hidden=>'true'},
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}"},"Cancel"),
      );
      print "</div>\n";
     
      if($g->{validate} eq 'true'){
        $g->{dbh}->do("remove from $table where $primary_id=$g->{$primary_id}");
        # send them back to default view...
        print "<script>window.location='$g->{scriptname}?function=$g->{function}'</script>\n";
      }
      elsif($g->{validate} eq 'false'){
        # send them back to default view...
        print "<script>window.location='$g->{scriptname}?function=$g->{function}'</script>\n";
      }
    }
  }
  elsif($g->{action} eq ''){ 
    $g->{action}='view';
    # view print qq(<p>view (default) $table </p>\n);
    my $query="select $primary_id,$view_fields from $table order by $orderby";
    print "\n<!-- $query -->\n";
    $sth=$g->{dbh}->prepare($query); $sth->execute;
    my $hashref = $sth->fetchall_hashref("$primary_id");
    my $count=0; 
    if($hashref ne ''){$count=1;}
    if($count==0){
      # no records found
      print "<h4 align='center'>There are no '$g->{function}' to view.</h4>\n";
    }
    else{
      # output table header
      print "<table class='table table-striped'>\n";
      print "  <thead>\n";
      print "    <tr>\n";
      foreach $col (split(/,/,$view_fields)){
        print "      <th>".$g->tc($col)."</th>";
      }
      print "      <th>\n";
      print "        Action\n";
#      if($g->{my_roles}=~m/edit/){ print " edit ";}
#      if($g->{my_roles}=~m/delete/){ print " edit ";}
      print "      </th>\n";
      print "    </tr>\n";
      print "  </thead>\n";
      
      # iterate hash and list data in table
      foreach $id (sort keys %{$hashref}){
        print "    <tr>\n";
        print "\n<!-- $primary_id: $id -->\n";
        foreach $key (keys %{ $hashref->{$id} }){
          if($key ne $primary_id){
            print "      <td>$hashref->{$id}->{$key}</td>\n";
          }
        }
        print "      <td>\n";
        if($g->{my_roles}=~m/edit/){ # edit 
          print $g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}&action=edit&$primary_id=$id"},
            $g->{CGI}->span({-class=>'glyphicon glyphicon-pencil', -aria-hidden=>'true', -title=>"Edit"}),
          );
        }
        if($g->{my_roles}=~m/del/){ # delete
          print "&nbsp;&nbsp;".$g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}&action=delete&$primary_id=$id"},
            $g->{CGI}->span({-class=>'glyphicon glyphicon-remove', -aria-hidden=>'true', -title=>"Delete"}),
          );
        }
        print "      </td>\n";
        print "    </tr>\n";
      }
      print "</table>\n";
    }
  }
  else{ # deny access to operation
    print $g->{CGI}->span({-class=>'glyphicon glyphicon-alert', -aria-hidden=>'true'},
      $g->{CGI}->h4({-align=>'center'},"You do not have access to perform the '$g->{action}' operation.  Contact your administrator."),
    );        
  }  
}

sub msg{ my ($msg)=@_; print $g->{CGI}->h3({-align=>"center"},"$msg");}
