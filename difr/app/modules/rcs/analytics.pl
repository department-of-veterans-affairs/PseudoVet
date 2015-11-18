my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'function',
  'default_function'=>'view',
  'function'=>{
    'add'=>'add',
    'create'=>'create',
    'view'=>'view',
    'delete'=>'delete_analytic',
  }
); &$function;
1;

sub view{
  print $g->{CGI}->h3("View");

  # show the global analytics that have already been composed
  # analytics('global');

  # show personalized analytics that the user has added
  # analytics('$g->{sys_username}');
}

sub create{
  # get arrays of all tables and pack into hash along with all table fields and possible field values
  my %a; my $tables=$g->{dbh}->selectcol_arrayref("show tables");
  foreach $table (@{$tables}){
    if($table=~m/^rcs/){
      $a{$table};
      print qq(<h3>$table</h3>);
      my $fields=$g->{dbh}->selectcol_arrayref("show fields from $table");
      foreach $field (@{$fields}){
        $a{$table}{$field};
        print qq(<h4>$field</h4>);
        my $values=$g->{dbh}->selectcol_arrayref("select distinct($field) from $table");
        foreach $value (@{$values}){
          $a{$table}{$field}{$value};
          print qq($value<br />);
        }
      }
    }
  }


  #drop down 'table' box, drop down 'field' box, dropdown 'value'
  # show a drop down form

}