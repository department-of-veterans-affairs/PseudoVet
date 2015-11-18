#!/usr/bin/perl

# show purchased tickets
# ----------------------
# allow editing of foresome group name and participant details

# Todo: need to use this often...
#
#    $g->event("users","$g->{sys_username} deleted '$g->{username}'");



if(not defined($g->{function}) and $g->{function} eq ''){$g->{function}='tickets';}

$g->system_menu_unrestricted("Purchases"=>"purchases","Tickets"=>"tickets");

print qq(\n<br /><br />\n);

my $function=$g->router(
  "key"=>'function',
  "default_key"=>'purchases',
  "default_function"=>'purchases',
  "function"=>{
    "purchases"=>'purchases',
    "tickets"=>'tickets',
    "details"=>'details',
  },
); &$function;

1; # end module

sub purchases{
  # show tickets that can have been purchased by the signed in user
  my $query="select charity_sponsors.name_or_group, charity_tickets.name, charity_tickets.description, charity_tickets.price
  from charity_tickets left join charity_sponsors on charity_tickets.id=charity_sponsors.ticket_id
  where charity_sponsors.username='$g->{sys_username}'";
  
  $sth=$g->{dbh}->prepare($query); $sth->execute or die("<p>Cannot execute query: $query</p>");
  my $count=0;
  while(my($name_or_group,$ticket_name,$description,$price)=$sth->fetchrow_array()){
    print "\n<div class='jumbotron'>\n";
    print "  <h2>$ticket_name - \$ $price\.00</h2>\n";
    print "  <h3>$description</h3>\n";
    print "  <h3>For (ticket holder/group): <em>$name_or_group</em></h3>\n";
    print "</div>\n";
    ++$count;
  }
  if($count==0){
    print "\n<div class='jumbotron'>\n";
    print "  <h4>You have no purchases at this time.</h4>\n";
    print "</div>\n";
  }  
}

sub details{
  print qq(<h4>details</h4>);
}

sub tickets{
  if($g->{action} eq ''){
    $g->{action}='view';

    my @fields=('id','name','description','image','event_id','venue_id','participants','price','checkout');
    my $table='charity_tickets';
    my $view_fields='name,price,description';    
    my $orderby='name';
    my $primary_id='id';

    print qq(<h4 align='center'>Select your level of sponsorship</h4>);

    my $query="select $primary_id,$view_fields from $table order by $orderby";
    print "\n<!-- $query -->\n";
    $sth=$g->{dbh}->prepare($query); $sth->execute;
    my $hashref = $sth->fetchall_hashref("$primary_id");
    if($hashref ne ''){$count=1;}
    if($count==0){
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
      print "      </th>\n";
      print "    </tr>\n";
      print "  </thead>\n";
      
      # iterate hash and list data in table
      foreach $id (sort keys %{$hashref}){
      my $linkvalues;
        print "    <tr>\n";
        print "\n<!-- $primary_id: $id -->\n";
        foreach $key (keys %{ $hashref->{$id} }){
          if($key ne $primary_id){
            print "      <td>$hashref->{$id}->{$key}</td>\n";
          }
          $linkvalues.="&$key=$hashref->{$id}->{$key}";
        }
        print "      <td>\n";
        
        # add button to select
        my $link="$g->{scriptname}?function=$g->{function}&action=select$linkvalues"; 
        print $g->{CGI}->a({-class=>"btn btn-primary btn-lg",-role=>"button",-href=>"$link"},"Select");
        print "      </td>\n";
        print "    </tr>\n";
      }
      print "</table>\n";
    }
  }
  elsif($g->{action} eq 'select'){
    # print the sponsorship data
    print $g->{CGI}->h4({-align=>"center"},"$g->{name} - \$$g->{price}");
        
    # generate a form to input participant data
    # select number of participants that goes with the ticket_id from the events table
    my ($num_participants,$checkout)=$g->{dbh}->selectrow_array("select participants,checkout from charity_tickets where id=$g->{id}");
    
    if($num_participants == 0){
        print $g->{CGI}->p({-align=>"center"},"Please enter your name as it should appear on your event ticket");
        # build empty form for non-golf sponsor
        print "    <div class=\"row\">\n";
        print "      <form action=\"$g->{scriptname}\" method=\"get\">\n";
        print "        <input type='hidden' name='function' value='$g->{function}' override>\n";
        print "        <input type='hidden' name='action' value='commit'>\n";
        print "        <input type='hidden' name='ticket_id' value='$g->{id}'>\n";
        print "        <input type='hidden' name='name' value='$g->{name}'>\n";
        print "        <input type='hidden' name='type' value='non-golf'>\n";
        print "        <div class=\"col-xs-6\">\n";

        print "        <div class=\"form-group\">\n";
        print "          <label for=\"name_or_group\">Sponsor Full Name</label>\n";
        print "          <input type=\"text\" class=\"form-control\" name=\"name_or_group\" placeholder=\"Player Full Name\">\n";
        print "        </div>\n";

        print "      <button type=\"submit\" class=\"btn btn-default\">Submit</button>\n";
        print "      </div>\n";
        print "    </form>\n";
        print "  </div>\n";        
    }
    elsif($num_participants == 1){
        print $g->{CGI}->p({-align=>"center"},"Please enter your name as it should appear on your event ticket");
        # build empty form for individual golf sponsor
        print "    <div class=\"row\">\n";
        print "      <form action=\"$g->{scriptname}\" method=\"get\">\n";
        print "        <input type='hidden' name='function' value='$g->{function}' override>\n";
        print "        <input type='hidden' name='action' value='commit'>\n";
        print "        <input type='hidden' name='ticket_id' value='$g->{id}'>\n";
        print "        <input type='hidden' name='name' value='$g->{name}'>\n";
        print "        <input type='hidden' name='type' value='individual'>\n";
        print "        <div class=\"col-xs-6\">\n";

        print "        <div class=\"form-group\">\n";
        print "          <label for=\"name_or_group\">Player Full Name</label>\n";
        print "          <input type=\"text\" class=\"form-control\" name=\"name_or_group\" placeholder=\"Player Full Name\">\n";
        print "        </div>\n";
        print "        <div class=\"form-group\">\n";
        print "          <label for=\"participant_email\">Player Email</label>\n";
        print "          <input type=\"text\" class=\"form-control\" name=\"participant_email\" placeholder=\"Player Email\">\n";
        print "        </div>\n";
        print "        <div class=\"form-group\">\n";
        print "          <label for=\"participant_hncp\">Player HNCP</label>\n";
        print "          <input type=\"text\" class=\"form-control\" name=\"participant_hncp\" placeholder=\"Player HNCP\">\n";
        print "        </div>\n";

        print "      <button type=\"submit\" class=\"btn btn-default\">Submit</button>\n";
        print "      </div>\n";
        print "    </form>\n";
        print "  </div>\n";            
    }
    # ask for participant names for foursomes
    elsif($num_participants == 4){
      print $g->{CGI}->h4({-align=>"center"},"Please enter the name of your foursome and participant details");      

        print "  <form action=\"$g->{scriptname}\" method=\"get\">\n";
        print "    <input type='hidden' name='function' value='$g->{function}' override>\n";
        print "    <input type='hidden' name='action' value='commit'>\n";
        print "    <input type='hidden' name='ticket_id' value='$g->{id}'>\n";
        print "    <input type='hidden' name='name' value='$g->{name}'>\n";
        print "    <input type='hidden' name='type' value='foursome'>\n";

        print "<div class='container'>\n";
        print "  <div class='row'>\n";
        print "    <div class='col-xs-6'>\n";
        print "        <div class=\"form-group\">\n";
        print "          <label for=\"name_or_group\">Name of Foursome</label>\n";
        print "          <input type=\"text\" class=\"form-control\" name=\"name_or_group\" placeholder=\"Full Name\">\n";
        print "        </div>\n";
        print "     </div>\n";
        print "  </div>\n";
        
        print "<table class='table table-striped'>\n";
        print "  <thead>\n";
        print "    <tr>\n";
        print "      <th>Player Name</th>\n";
        print "      <th>Player Email</th>\n";
        print "      <th>Player HNCP</th>\n";
        print "    </tr>\n";
        print "  </thead>\n";

        print "  <tr>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_1_name\" placeholder=\"Participant 1 Name\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_1_email\" placeholder=\"Participant 1 Email\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_1_hncp\" placeholder=\"Participant 1 HNCP\"></td>\n";
        print "  </tr>\n";
        print "  <tr>\n";

        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_2_name\" placeholder=\"Participant 2 Name\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_2_email\" placeholder=\"Participant 2 Email\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_2_hncp\" placeholder=\"Participant 2 HNCP\"></td>\n";
        print "  </tr>\n";
        print "  <tr>\n";

        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_3_name\" placeholder=\"Participant 3 Name\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_3_email\" placeholder=\"Participant 3 Email\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_3_hncp\" placeholder=\"Participant 3 HNCP\"></td>\n";
        print "  </tr>\n";
        print "  <tr>\n";

        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_4_name\" placeholder=\"Participant 4 Name\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_4_email\" placeholder=\"Participant 4 Email\"></td>\n";
        print "    <td><input type=\"text\" class=\"form-control\" name=\"participant_4_hncp\" placeholder=\"Participant 4 HNCP\"></td>\n";
        print "  </tr>\n";
        print "</table>\n";

        print "      <center><button type=\"submit\" class=\"btn btn-default\">Submit</button></center>\n";
        print "    </form>\n";
        print "</div> <!-- close container -->\n";

#        # build empty form for foursome sponsor
#        print "    <div class=\"row\">\n";
#        print "      <form action=\"$g->{scriptname}\" method=\"get\">\n";
#        print "        <input type='hidden' name='function' value='$g->{function}' override>\n";
#        print "        <input type='hidden' name='action' value='commit'>\n";
#        print "        <input type='hidden' name='ticket_id' value='$g->{id}'>\n";
#        print "        <input type='hidden' name='name' value='$g->{name}'>\n";
#        print "        <input type='hidden' name='type' value='foursome'>\n";
#        print "        <div class=\"col-xs-6\">\n";
#
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"name_or_group\">Name of Foursome</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"name_or_group\" placeholder=\"Full Name\">\n";
#        print "        </div>\n";
#
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_1_name\">Participant 1 Name</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_1_name\" placeholder=\"Participant 1 Name\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_1_email\">Participant 1 Email</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_1_email\" placeholder=\"Participant 1 Email\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_1_hncp\">Participant 1 HNCP</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_1_hncp\" placeholder=\"Participant 1 HNCP\">\n";
#        print "        </div>\n";
#
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_2_name\">Participant 2 Name</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_2_name\" placeholder=\"Participant 2 Name\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_2_email\">Participant 2 Email</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_2_email\" placeholder=\"Participant 2 Email\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_2_hncp\">Participant 2 HNCP</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_2_hncp\" placeholder=\"Participant 2 HNCP\">\n";
#        print "        </div>\n";
#
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_3_name\">Participant 3 Name</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_3_name\" placeholder=\"Participant 3 Name\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_3_email\">Participant 3 Email</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_3_email\" placeholder=\"Participant 3 Email\">\n";
#        print "        </div>\n";
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_3_hncp\">Participant 3 HNCP</label>\n";
#        print "          <input type=\"text\" class=\"form-control\" name=\"participant_3_hncp\" placeholder=\"Participant 3 HNCP\">\n";
#        print "        </div>\n";
#
#        print "        <div class=\"form-group\">\n";
#        print "          <label for=\"participant_4_name\">Participant 4 Name</label>\n";
 #       print "          <input type=\"text\" class=\"form-control\" name=\"participant_4_name\" placeholder=\"Participant 4 Name\">\n";
 #       print "        </div>\n";
 #       print "        <div class=\"form-group\">\n";
 #       print "          <label for=\"participant_4_email\">Participant 4 Email</label>\n";
 #       print "          <input type=\"text\" class=\"form-control\" name=\"participant_4_email\" placeholder=\"Participant 4 Email\">\n";
 #       print "        </div>\n";
 #       print "        <div class=\"form-group\">\n";
 #       print "          <label for=\"participant_4_hncp\">Participant 4 HNCP</label>\n";
 #       print "          <input type=\"text\" class=\"form-control\" name=\"participant_4_hncp\" placeholder=\"Participant 4 HNCP\">\n";
 #       print "        </div>\n";
#
#        print "      <button type=\"submit\" class=\"btn btn-default\">Submit</button>\n";
#        print "      </div>\n";
#        print "    </form>\n";
#        print "  </div>\n";
    }
    
    # upon post will commit and write ticket details
  }
  elsif($g->{action} eq 'commit'){
    # this stage saves sponsor and participant data
    print "\n<!-- commit -->\n";
    
    my $sponsor_insert="insert into charity_sponsors values(
      0,'$g->{sys_username}','$g->{ticket_id}','$g->{name_or_group}',NULL,NULL,NULL
    )";
    
    if($g->{type} eq 'non-golf'){
      $g->{dbh}->do($sponsor_insert);
      print "\n<!-- non-golf: $sponsor_insert -->\n";
    }
    elsif($g->{type} eq 'individual'){
      $g->{dbh}->do($sponsor_insert);

      print "\n<!-- individual: $sponsor_insert -->\n";

      my $player_insert="insert into charity_players values(
        0,'$g->{name_or_group}','$g->{name_or_group}','$g->{participant_email}','$g->{participant_hncp}'
      )"; $g->{dbh}->do($player_insert);
      
      print "\n<!-- individual: $player_insert -->\n";
    }
    elsif($g->{type} eq 'foursome'){
      $g->{dbh}->do($sponsor_insert);

      $g->{name_or_group}=~s/\'//g;       
      $g->{name_or_group}=~s/\"//g;

      print "\n<!-- foursome: $sponsor_insert -->\n";

      my $player_insert="insert into charity_players values(
        0,'$g->{name_or_group}','$g->{participant_1_name}','$g->{participant_1_email}','$g->{participant_1_hncp}'
      )"; $g->{dbh}->do($player_insert);

      print "\n<!-- foursome: $player_insert -->\n";
      
      $player_insert="insert into charity_players values(
        0,'$g->{name_or_group}','$g->{participant_2_name}','$g->{participant_2_email}','$g->{participant_2_hncp}'
      )"; $g->{dbh}->do($player_insert);

      print "\n<!-- foursome: $player_insert -->\n";

      $player_insert="insert into charity_players values(
        0,'$g->{name_or_group}','$g->{participant_3_name}','$g->{participant_3_email}','$g->{participant_3_hncp}'
      )"; $g->{dbh}->do($player_insert);

      print "\n<!-- foursome: $player_insert -->\n";

      $player_insert="insert into charity_players values(
        0,'$g->{name_or_group}','$g->{participant_4_name}','$g->{participant_4_email}','$g->{participant_4_hncp}'
      )"; $g->{dbh}->do($player_insert);

      print "\n<!-- foursome: $player_insert -->\n";

    }  
    ## preview before they click checkout
    my $query="select charity_sponsors.name_or_group, charity_tickets.name, charity_tickets.description, charity_tickets.price
    from charity_tickets left join charity_sponsors on charity_tickets.id=charity_sponsors.ticket_id
    where charity_sponsors.username='$g->{sys_username}' and charity_sponsors.name_or_group='$g->{name_or_group}'";
    
    $sth=$g->{dbh}->prepare($query); $sth->execute or die("<p>Cannot execute query: $query</p>");
    while(my($name_or_group,$ticket_name,$description,$price)=$sth->fetchrow_array()){
  
      print "\n<div class='jumbotron'>\n";
      print "  <h2>$ticket_name - \$ $price\.00</h2>\n";
      print "  <h3>$description</h3>\n";
      print "  <h3>For (ticket holder/group): <em>$name_or_group</em></h3>\n";
      print "</div>\n";
    }

    ## give user the button for checkout
    my $checkout=$g->{dbh}->selectrow_array("select checkout from charity_tickets where id=$g->{ticket_id}");
    print "<center>$checkout</div>\n";
  }
  elsif($g->{action} eq 'checkout'){
    # route user to paypal checkout button
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
        
        # add button to select
        print $g->{CGI}->a({-href=>"$g->{scriptname}?function=$g->{function}&action=edit&$primary_id=$id"},
          $g->{CGI}->span({-class=>'glyphicon glyphicon-pencil', -aria-hidden=>'true', -title=>"Edit"}),
        );
        
        
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
