#!/usr/bin/perl
# studies module for DIFR
# If you don't know the code, don't mess around below -bciv

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'view',
  'default_function'=>'view',
  'function'=>{
    'list'=>'view',
    'review'=>'review',
    'update'=>'review',
    'query'=>'view',
  }
); &$function;
1; # end module

sub review{
  my($last,$first,$middle,$suffix,$degree)=$g->{dbh}->selectrow_array("select lastname,firstname,middle,suffix,degree from rcs_personnel where uid=$g->{uid}");
  my $employee="$last, $first $middle $suffix $degree";
  my $checklist_tbl="rcs_checklist_full_initial_review";
  my $error_message;
  # handle record creation
  if($g->{checklist_id} eq ''){
    my $exists=$g->{dbh}->selectrow_array("select id from $checklist_tbl where uid='$g->{uid}' and scopeid='$g->{scopeid}'");
    # insert new record
    if($exists eq ''){
      $g->{dbh}->do("insert into $checklist_tbl values(0,'$g->{uid}','$g->{scopeid}','$g->{irbnumber}','','','','','','','','','','',
      '','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
      '','','','','','','','','','','','')");
    }
  }
  # handle updates
  my $fieldlist=$g->fields("$checklist_tbl");
  my @fields=split(/\,/,$fieldlist);

  if($g->{function} eq 'update'){
#    my $fieldlist=$g->fields("$checklist_tbl");
#    my @fields=split(/\,/,$fieldlist);
    my $update_query="update $checklist_tbl ";
    my $count=0;
    foreach $field (@fields){
      if($field ne 'uid' and $field ne 'id' and $g->{$field} ne ''){
        if($count eq '0'){$update_query.="set $field=\"$g->{$field}\", ";}
        else{$update_query.="$field=\"$g->{$field}\", ";}
        ++$count;
      }
    }
    $update_query=~s/\,\s+$//;
    $update_query.=" where uid='$g->{uid}' and scopeid='$g->{scopeid}' and id='$g->{id}'";
    print "\n\n<!-- update_query: $update_query -->\n\n";
    $sth=$g->{dbh}->prepare("$update_query"); $sth->execute() or $error_message="[Update Failed] :: $!";
  }
  my $getquery="select $fieldlist from $checklist_tbl where uid='$g->{uid}' and scopeid='$g->{scopeid}'";
  print "<!-- getquery: $getquery -->\n";
  my $f=$g->{dbh}->selectrow_hashref("$getquery");
  my %dsc=("yes"=>"Yes (No Further Docs.)","no"=>"No (Req. DTA and ISO)",""=>"Select...");
  my %acorp=("yes"=>"Yes","no"=>"No",""=>"Select...");
  my %boolean=("true"=>"True","false"=>"False",""=>"Select...");

  my $error_link='';
  if($error_message ne ''){
    $error_link=qq(<a style='float: right; color: red;' href="mailto:support\@etherfeat.com?subject=$g->{appname}::$g->{sys_mod} Error $g->{sys_username} $g->{sys_sid}&body=Error report: $g->{sys_time} $g->{sys_sid} $g->{sys_vars} $error_message">Update Failed! [Report This Error]</a>);
  }

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"javascript: history.go(-1)"},"Back"),
  ),
  qq(<div id="page_effect" style="display:none;>),
  $g->{CGI}->div({-id=>"title"},$g->{CGI}->h3("$employee\'s Full Initial Review / Minimal Risk Studies")),
  $g->{CGI}->div({-id=>"subtitle"},$g->{CGI}->h3("$g->{projecttitle} $error_link")),
  $g->{CGI}->div({-id=>'main'},
    $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}",-name=>"foo"}),
    $g->{CGI}->div({-id=>'record'},
      $g->{CGI}->hidden({-name=>"action",-value=>"review"}),
      $g->{CGI}->hidden({-name=>"projecttitle",-value=>"$g->{projecttitle}"}),
      $g->{CGI}->hidden({-name=>"function",-value=>"update"},-override=>1),
      $g->{CGI}->hidden({-name=>"id",-value=>"$f->{id}"}),
      $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}"}),
      $g->{CGI}->hidden({-name=>"scopeid",-value=>"$g->{scopeid}"}),
      $g->{CGI}->label({-for=>"irbnumber"},"IRB Number: ",
        $g->{CGI}->b("$f->{irbnumber}"),
      ),
      $g->{CGI}->hidden({-name=>"irbnumber",-value=>"$f->{irbnumber}"}),
      $g->{CGI}->label({-for=>"iacucnum"},"IACUC Number: "),
      $g->{CGI}->textfield({-name=>"iacucnum",-value=>"$f->{iacucnum}",-override=>1}),
      $g->{CGI}->label({-for=>"randdnum"},"R&D Number: "),
      $g->{CGI}->textfield({-name=>"randdnum",-value=>"$f->{randdnum}",-override=>1}),
      $g->{CGI}->submit({-style=>"float: right",-value=>"Save"}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
    ),
    $g->{CGI}->div({-id=>'record'},
      $g->{CGI}->h3("Three Copies of:"),
      $g->{CGI}->label({-for=>"req_to_review_packet",-class=>"fixed"},"Request to review pkt"),
	  	$g->{CGI}->textfield({-id=>"datepicker1",-name=>"req_to_review_packet",-value=>"$f->{req_to_review_packet}",-size=>"11",-override=>"1",
	  	}),
      $g->{CGI}->label({-for=>"abstract",-class=>"fixed"},"Abstract"),
	  	$g->{CGI}->textfield({-id=>"datepicker2",-name=>"abstract",-value=>"$f->{abstract}",-size=>"11",-override=>"1"}),
      $g->{CGI}->label({-for=>"disclosure",-class=>"fixed"},"Disclosure"),
	  	$g->{CGI}->textfield({-id=>"datepicker3",-name=>"disclosure",-value=>"$f->{disclosure}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"key_personnel",-class=>"fixed"},"Key Personnel"),
	  	$g->{CGI}->textfield({-id=>"datepicker4",-name=>"key_personnel",-value=>"$f->{key_personnel}",-size=>"11",-override=>"1",-onClick=>"",}),
      $g->{CGI}->label({-for=>"biosafety_form",-class=>"fixed"},"BioSafety"),
	  	$g->{CGI}->textfield({-id=>"datepicker5",-name=>"biosafety_form",-value=>"$f->{biosafety_form}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"code_of_ethics",-class=>"fixed"},"Code of Ethics"),
	  	$g->{CGI}->textfield({-id=>"datepicker6",-name=>"code_of_ethics",-value=>"$f->{code_of_ethics}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"dsc",-class=>"fixed"},"DSC (Appendix C\&D)"),
	  	$g->{CGI}->textfield({-id=>"datepicker7",-name=>"dsc",-value=>"$f->{dsc}",-size=>"11",-override=>"1",-onClick=>""}),
	  	$g->{CGI}->popup_menu({-name=>"dsc_details",-default=>"$f->{dsc_details}",-values=>\%dsc,-size=>"1",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"va_acknowledgement",-class=>"fixed"},"ACK of VA in Research"),
	  	$g->{CGI}->textfield({-id=>"datepicker8",-name=>"va_acknowledgement",-value=>"$f->{va_acknowledgement}",-size=>"11",-override=>"1",-onClick=>""}),
		  $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"iacuc_proposal_approval",-class=>"fixed"},"Full Proposal approved by IACUC"),
	  	$g->{CGI}->textfield({-id=>"datepicker9",-name=>"iacuc_proposal_approval",-value=>"$f->{iacuc_proposal_approval}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"copies_of_budget",-class=>"fixed"},"Budget"),
	  	$g->{CGI}->textfield({-id=>"datepicker10",-name=>"copies_of_budget",-value=>"$f->{copies_of_budget}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"investigator_brochure",-class=>"fixed"},"Investigator Brochure, if applicable"),
	  	$g->{CGI}->textfield({-id=>"datepicker11",-name=>"investigator_brochure",-value=>"$f->{investigator_brochure}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"animal_component",-class=>"fixed"},"Animal Component (4 Copies)(if req.)"),
	  	$g->{CGI}->textfield({-id=>"datepicker12",-name=>"animal_component",-value=>"$f->{animal_component}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"sponsor_letter",-class=>"fixed"},"Sponsor\'s Letter (4 copies)(if req.)"),
	  	$g->{CGI}->textfield({-id=>"datepicker13",-name=>"sponsor_letter",-value=>"$f->{sponsor_letter}",-size=>"11",-override=>"1",-onClick=>""}),
			$g->{CGI}->br(),
			$g->{CGI}->fieldset(
        $g->{CGI}->label({-for=>"acorp",-class=>"fixed"},"ACORP Application?"),
	  	  $g->{CGI}->popup_menu({-name=>"acorp",-default=>"$f->{acorp}",-values=>\%acorp,-size=>"1",-override=>"1",-onClick=>""}),
        $g->{CGI}->label({-for=>"pi_signature",-class=>"fixed"},"PI Signature"),
	  	  $g->{CGI}->textfield({-id=>"datepicker14",-name=>"pi_signature",-value=>"$f->{pi_signature}",-size=>"11",-override=>"1",-onClick=>""}),
        $g->{CGI}->label({-for=>"iacuc_signature",-class=>"fixed"},"IACUC Chair Signature"),
	  	  $g->{CGI}->textfield({-id=>"datepicker15",-name=>"iacuc_signature",-value=>"$f->{iacuc_signature}",-size=>"11",-override=>"1",-onClick=>""}),
        $g->{CGI}->label({-for=>"dvm_signature",-class=>"fixed"},"DVM Signature"),
	  	  $g->{CGI}->textfield({-id=>"datepicker16",-name=>"dvm_signature",-value=>"$f->{dvm_signature}",-size=>"11",-override=>"1",-onClick=>""}),
		  ),
		),
		$g->{CGI}->div({-id=>"record"},
		  $g->{CGI}->h3("Concurrence Letters"),
      $g->{CGI}->label({-for=>"service_chief_ltr"},"Department Chairperson/VA Service Chief"),
	  	$g->{CGI}->textfield({-id=>"datepicker17",-name=>"service_chief_ltr",-value=>"$f->{service_chief_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"section_chief_ltr"},"Division Director/VA Section Chief"),
	  	$g->{CGI}->textfield({-id=>"datepicker18",-name=>"section_chief_ltr",-value=>"$f->{section_chief_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"radiation_ltr"},"Isotope Radiation Safety Committee"),
	  	$g->{CGI}->textfield({-id=>"datepicker19",-name=>"radiation_ltr",-value=>"$f->{radiation_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"privacy_ltr"},"Privacy/ISO Memo"),
	  	$g->{CGI}->textfield({-id=>"datepicker20",-name=>"privacy_ltr",-value=>"$f->{privacy_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"laboratory_ltr"},"Laboratory Service"),
	  	$g->{CGI}->textfield({-id=>"datepicker21",-name=>"laboratory_ltr",-value=>"$f->{laboratory_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"ord_approval_ltr"},"ORD approval for tissue banking/storage"),
	  	$g->{CGI}->textfield({-id=>"datepicker22",-name=>"ord_approval_ltr",-value=>"$f->{ord_approval_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"safety_sub_ltr"},"Safety Subcommittee approval with Chair signature"),
	  	$g->{CGI}->textfield({-id=>"datepicker23",-name=>"safety_sub_ltr",-value=>"$f->{safety_sub_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
		  $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"nucmed_ltr"},"Nuclear Medicine"),
	  	$g->{CGI}->textfield({-id=>"datepicker24",-name=>"nucmed_ltr",-value=>"$f->{nucmed_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"cardiology_ltr"},"Cardiology Section"),
	  	$g->{CGI}->textfield({-id=>"datepicker25",-name=>"cardiology_ltr",-value=>"$f->{cardiology_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"dta_ltr"},"DTA (Data Transfer Agreement)"),
	  	$g->{CGI}->textfield({-id=>"datepicker26",-name=>"dta_ltr",-value=>"$f->{dta_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"radiology_ltr"},"Radiology Service"),
	  	$g->{CGI}->textfield({-id=>"datepicker27",-name=>"radiology_ltr",-value=>"$f->{radiology_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"pharmacy_ltr"},"Pharmacy Service"),
	  	$g->{CGI}->textfield({-id=>"datepicker28",-name=>"pharmacy_ltr",-value=>"$f->{pharmacy_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"custom1_ltr"},
	  	  $g->{CGI}->textfield({-name=>"custom1_name",-value=>"$f->{custom1_name}",-size=>"30",-override=>"1"}),
		  ),
	  	$g->{CGI}->textfield({-id=>"datepicker29",-name=>"custom1_ltr",-value=>"$f->{custom1_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"custom2_ltr"},
	  	  $g->{CGI}->textfield({-name=>"custom2_name",-value=>"$f->{custom2_name}",-size=>"30",-override=>"1"}),
		  ),
	  	$g->{CGI}->textfield({-id=>"datepicker30",-name=>"custom2_ltr",-value=>"$f->{custom2_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"custom3_ltr"},
	  	  $g->{CGI}->textfield({-name=>"custom3_name",-value=>"$f->{custom3_name}",-size=>"30",-override=>"1"}),
		  ),
	  	$g->{CGI}->textfield({-id=>"datepicker31",-name=>"custom3_ltr",-value=>"$f->{custom3_ltr}",-size=>"11",-override=>"1",-onClick=>""}),

      $g->{CGI}->label({-for=>"custom4_ltr"},
	  	$g->{CGI}->textfield({-name=>"custom4_name",-value=>"$f->{custom4_name}",-size=>"30",-override=>"1"}),
		  ),
	  	$g->{CGI}->textfield({-id=>"datepicker32",-name=>"custom4_ltr",-value=>"$f->{custom4_ltr}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
    ),
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->h3("Budget"),
      $g->{CGI}->label({-for=>"budget_funded"},"There is a Budget"),
	  	$g->{CGI}->popup_menu({-name=>"budget_funded",-default=>"$f->{budget_funded}",-values=>\%boolean,-size=>"1",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"support_fees"},"Support Service Fees"),
	  	$g->{CGI}->popup_menu({-name=>"support_fees",-default=>"$f->{support_fees}",-values=>\%boolean,-size=>"1",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"new_pi"},"Employee is New PI"),
	  	$g->{CGI}->popup_menu({-name=>"new_pi",-default=>"$f->{new_pi}",-values=>\%boolean,-size=>"1",-override=>"1",-onClick=>""}),
      $g->{CGI}->fieldset(
        $g->{CGI}->label({-for=>"admin_fees"},"Research Service Administrative Service Fee for non VA funded studies"),
	  	  $g->{CGI}->popup_menu({-name=>"admin_fees",-default=>"$f->{admin_fees}",-values=>\%boolean,-size=>"1",-override=>"1",-onClick=>""}),
		    $g->{CGI}->p({-style=>"text-style: italic"},"(Not applicable for RR\&D, Merit Review, etc.)"),
      ),
    ),
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->h3("New PI's Only"),
      $g->{CGI}->label({-for=>"page18"},"Page 18 (Blue Sheet)"),
	  	$g->{CGI}->textfield({-id=>"datepicker33",-name=>"page18",-value=>"$f->{page18}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"inv_datasheet"},"Investigator Data Sheet"),
	  	$g->{CGI}->textfield({-id=>"datepicker34",-name=>"inv_datasheet",-value=>"$f->{inv_datasheet}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"ttpc_cert"},"Technology Transfer Program Certification"),
	  	$g->{CGI}->textfield({-id=>"datepicker35",-name=>"ttpc_cert",-value=>"$f->{ttpc_cert}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
    ),
    $g->{CGI}->div({-id=>"record"},
      #orientation_arf,orientation_hra,orientation_request,orientation_annual
      $g->{CGI}->h3("Orientation by Comparative Medicine"),
      $g->{CGI}->label({-for=>"orientation_arf"},"Orientation to VA ARF (VA Manager)"),
	  	$g->{CGI}->textfield({-id=>"datepicker36",-name=>"orientation_arf",-value=>"$f->{orientation_arf}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->label({-for=>"orientation_hra"},"Health Risk Assessment (VA Manager)"),
	  	$g->{CGI}->textfield({-id=>"datepicker37",-name=>"orientation_hra",-value=>"$f->{orientation_hra}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"orientation_request"},"Request for orientation \& certification of new research personnel (Comp. med)"),
	  	$g->{CGI}->textfield({-id=>"datepicker38",-name=>"orientation_request",-value=>"$f->{orientation_request}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"orientation_annual"},"Annual recertification of research personnel (Comp. med)"),
	  	$g->{CGI}->textfield({-id=>"datepicker39",-name=>"orientation_annual",-value=>"$f->{orientation_annual}",-size=>"11",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"certificate"},"Certificate"),
	  	$g->{CGI}->textfield({-id=>"",-name=>"certificate",-value=>"$f->{certificate}",-size=>"30",-override=>"1",-onClick=>""}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
      $g->{CGI}->end_form(),
    ),
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->submit({-style=>"float: right",-value=>"Save"}),
      $g->{CGI}->br(),
      $g->{CGI}->br(),
    ),
    $g->{CGI}->br(),
  );
}

sub view{
  tabs();
	print $g->{CGI}->br(),$g->{CGI}->h3("Studies");
  analytics();
  search();

  if(not defined($g->{type}) or $g->{type} eq ''){$g->{type}='all';}

  if(not defined($g->{view})){
    $g->{view}='all';

    print qq(<div id="page_effect" style="display:none;">\n);

    print $g->{CGI}->br(),$g->{CGI}->br(),
    $g->{CGI}->h4({-align=>"center"},"Select A Study type or Search Criteria.");
    return;
  }

  if(not defined($g->{type}) or $g->{type} eq ''){$g->{type}="all"; }
  my $ftype=''; my $studies_query="and $g->{type}=\"true\"";
  if($g->{type} eq "human"){$ftype="Human";}
  elsif($g->{type} eq "nonhuman"){$ftype="Animal";}
  elsif($g->{type} eq "basic"){$ftype="Basic Science";}
  elsif($g->{type} eq "all"){$ftype="All"; $studies_query='';}

  my $query_fields="uid,lastname,firstname,middle,suffix,degree,status,nacicleared,saccleared,credentialed,credcomment,suspended";

  if($g->{action} eq "list"){ # list query by matching ^$g->{letter}
    $sth=$g->{dbh}->prepare("select $query_fields from rcs_personnel where lastname like \"$g->{letter}%\" $studies_query order by lastname");
    $sth->execute();
  }
  elsif($g->{action} eq "query"){ # list records =~ $g->{query} [lastname|firstname|ssn]
    $sth=$g->{dbh}->prepare("select $query_fields from rcs_personnel where (lastname like \"$g->{query}%\"
    or firstname like \"$g->{query}%\" or ssn like \"$g->{query}%\") $studies_query order by lastname, firstname"); $sth->execute();
  }
  else{ # give full listing for people that use the scroll bar...
    my $adjusted_studies_query="where $g->{type}=\"true\""; if($g->{type} eq 'all'){$adjusted_studies_query='';}
    $sth=$g->{dbh}->prepare("select $query_fields from rcs_personnel $adjusted_studies_query order by lastname, firstname"); $sth->execute();
  }

  #search();
  print qq(\n<div id="page_effect" style="display:none;">\n);

  print $g->{CGI}->start_table({-cols=>"6",-cellspacing=>"0",-cellpadding=>"0",-border=>"1",-width=>"99%"}),
  $g->{CGI}->Tr(
    $g->{CGI}->th("Name"),
    $g->{CGI}->th("Status"),
    $g->{CGI}->th("License"),
    $g->{CGI}->th("Education"),
    $g->{CGI}->th({-width=>"30%"},"Project Roles"),
    $g->{CGI}->th("Background"),
  );
  my $output=0;
  while(my($uid,$lastname,$firstname,$middle,$suffix,$degree,$status,$nacicleared,$saccleared,$credentialed,$wocexempt,$suspended)=$sth->fetchrow_array()){
    if(defined($g->{view})){
      if ($g->{view} eq "VA"){unless($status eq "VA"){next;}}
      if ($g->{view} eq "VA WOC"){unless($status eq "VA WOC"){next;}}
      if ($g->{view} eq "WOC"){unless($status eq "WOC"){next;}}
      if ($g->{view} eq "WOC Exempt"){unless($status eq "WOC Exempt"){next;}}
      if ($g->{view} eq "Foundation"){unless($status eq "Foundation"){next;}}
    }

    # name of person
    my $namecolor="#000000";
    if($suspended eq "s"){$namecolor="red";}
    elsif($suspended eq "p"){$namecolor="orange";}

    print "<Tr>",$g->{CGI}->td({-width=>"100"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$uid",-title=>"click to view personnel record"},
      "<font color=\"$namecolor\">$lastname, $firstname $middle $suffix $degree</font>",
    )),

    # status: VA, WOC, or WOC Exempt (exempt from background check)
    $g->{CGI}->td({-align=>"center",-width=>"40"},"$status");

    # licenses
   print "<td align=\"left\" width=\"120\">";
   $rc=$g->{dbh}->prepare("select lid,type,number,state,expires,status from rcs_license where uid=\"$uid\""); $rc->execute();
   my $noli=0; my $licensedivider=0;

   # the $lstatus (status: inactive,active,delinquent) is ignored here I just put it here so we know that it exists in the table...
   my $license_count=0;
   while(my($lid,$typ,$num,$st,$exp,$lstatus)=$rc->fetchrow_array()){
     if($licensedivider >0){print "<hr>";} ++$licensedivider;
     if($exp ne "0000-00-00"){$exp=sprintf("%02.0f/%02.0f/%04.0f",substr($exp,5,2),substr($exp,8,2),substr($exp,0,4));}else{$exp="<font color=black>Unk</font>";}
     #if($ver ne "0000-00-00"){$ver=sprintf("%02.0f/%02.0f/%04.0f",substr($ver,5,2),substr($ver,8,2),substr($ver,0,4));}else{$ver="<font color=red>No</font>";}
     print $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_license&action=edit&uid=$uid&lid=$lid",-title=>"$num $st $typ"},"$typ<br />exp: $exp<br />");
     $noli=1;
     ++$license_count;
   }
   if($license_count eq "0"){print "<center>No Licenses</center>";}

   if($noli==0){print "&nbsp;";}
   print "</td>",

    # education
    "<td align=\"left\" width=\"100\">";
    my $ed=$g->{dbh}->prepare("select eid,degree,firstreq,secondreq,verified from rcs_education where uid=$uid"); $ed->execute();
    my $noed=0; my $educationdivider=0;
    while(my($eid,$degree,$firstreq,$secondreq,$veried)=$ed->fetchrow_array()){
      if($educationdivider>0){print "<hr>";} ++$educationdivider;
      if($firstreq ne "0000-00-00"){$firstreq=sprintf("%02.0f/%02.0f/%04.0f",substr($firstreq,5,2),substr($firstreq,8,2),substr($firstreq,0,4));}else{$firstreq="<font color=black>None</font>";}
      if($secondreq ne "0000-00-00"){$secondreq=sprintf("%02.0f/%02.0f/%04.0f",substr($secondreq,5,2),substr($secondreq,8,2),substr($secondreq,0,4));}else{$secondreq="<font color=red>None</font>";}
      if($veried ne "0000-00-00"){$veried=sprintf("%02.0f/%02.0f/%04.0f",substr($veried,5,2),substr($veried,8,2),substr($veried,0,4));}else{$veried="<font color=red>No</font>";}
      print $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_education&action=edit&uid=$uid&eid=$eid",
                   -title=>"$degree"},"$degree<br />R1: $firstreq<br />R2: $secondreq<br />Ver: $veried<br />");
      $noed=1;
    }
    if($noed==0){print "<center>No Degrees</center>";}
    #}
    print "</td>",

    # SOW ~scope of work
    "<td align=\"center\" width=\"100\">";
    my $projects=$g->{dbh}->prepare("select rcs_project_members.scopeid,rcs_project_members.role,rcs_scopeofwork.irbnumber,rcs_scopeofwork.projecttitle
                                     from rcs_project_members left join rcs_scopeofwork on rcs_project_members.scopeid=rcs_scopeofwork.scopeid
                                     where rcs_project_members.uid=\"$uid\""); $projects->execute();
    my $project_count="0";
    while(my($scopeid,$role,$irb,$title)=$projects->fetchrow_array()){
      print $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_projects&action=projects#$scopeid"},"$irb $title &#149; \($role\)");
      my $checklist_id=$g->{dbh}->selectrow_array("select id from rcs_checklist_full_initial_review where scopeid=$scopeid and uid=$uid");
      print $g->{CGI}->br(),$g->{CGI}->a({-href=>"$g->{scriptname}?action=review&scopeid=$scopeid&uid=$uid&checklist_id=$checklist_id&projecttitle=$title&irbnumber=$irb"},"Inital Review"),
      ,$g->{CGI}->hr();
      ++$project_count;
    }
    if($project_count eq "0"){print "Not Involved In Any Projects";}
    print "</td>"; # from ,

    # background
    if($nacicleared ne "0000-00-00"){$backgroundsent=sprintf("%02.0f/%02.0f/%04.0f",substr($nacicleared,5,2),substr($nacicleared,8,2),substr($nacicleared,0,4));}else{$nacicleared="<font color=black>No</font>";}
    if($saccleared ne "0000-00-00"){$saccleared=sprintf("%02.0f/%02.0f/%04.0f",substr($saccleared,5,2),substr($saccleared,8,2),substr($saccleared,0,4));}else{$saccleared="<font color=red>No</font>";}
    if($status eq "VA"){print $g->{CGI}->td({-align=>"center"},"N/A");}
    elsif($status eq "WOC Exempt"){print $g->{CGI}->td({-align=>"left",-title=>"$wocexempt"},"Exempt");}
    else{print $g->{CGI}->td({-align=>"left"},"Cleared:<br />NACI: $nacicleared<br />SAC: $saccleared");}
    print "</Tr>";

    $output=1;
  } # this is the end of the while loop that iterates through the personnel listing

  if($output eq '0'){
    print $g->{CGI}->Tr($g->{CGI}->td({-colspan=>"6"},"There are no employees who match the current criteria."),);
  }
  print $g->{CGI}->end_table();
}

sub tabs{
  my $selected='selected';
  my $viewallselected=''; if($g->{view} eq 'all'){$viewallselected=$selected;}
  my $viewvaselected='';  if($g->{view} eq 'VA'){$viewvaselected=$selected;}
  my $viewvawocselected='';  if($g->{view} eq 'VA WOC'){$viewvawocselected=$selected;}
  my $viewwocselected='';  if($g->{view} eq 'WOC'){$viewwocselected=$selected;}
  my $viewwoceselected=''; if($g->{view} eq 'WOC Exempt'){$viewwoceselected=$selected;}
  my $viewwocdselected=''; if($g->{view} eq 'WOC Doctor'){$viewwocdselected=$selected;}

  print $g->{CGI}->div({-id=>"horizontalmenu"},
	$g->{CGI}->ul({-id=>"horizontalmenu"},
	  $g->{CGI}->li({-class=>"$viewallselected"},$g->{CGI}->span($g->{CGI}->a({-href=>"$g->{scriptname}?&view=all&type=$g->{type}"},"View All"),),),
	  $g->{CGI}->li({-class=>"$viewvaselected"},$g->{CGI}->span($g->{CGI}->a({-href=>"$g->{scriptname}?view=VA&type=$g->{type}"},"VA"),),),
	  $g->{CGI}->li({-class=>"$viewvawocselected"},$g->{CGI}->span($g->{CGI}->a({-href=>"$g->{scriptname}?view=VA WOC&type=$g->{type}"},"VA WOC"),),),
	  $g->{CGI}->li({-class=>"$viewwocselected"},$g->{CGI}->span($g->{CGI}->a({-href=>"$g->{scriptname}?view=WOC&type=$g->{type}"},"WOC"),),),
	  $g->{CGI}->li({-class=>"$viewwoceselected"},$g->{CGI}->span($g->{CGI}->a({-href=>"$g->{scriptname}?view=WOC Exempt&type=$g->{type}"},"WOC Exempt"),),),
	),
  );
}

sub search{
  my $selected='selected';
  my $allselected=''; if($g->{type} eq 'all'){$allselected=$selected;}
  my $humanselected='';  if($g->{type} eq 'human'){$humanselected=$selected;}
  my $nonhumanselected=''; if($g->{type} eq 'nonhuman'){$nonhumanselected=$selected;}
  my $basicsciencesselected=''; if($g->{type} eq 'basic'){$basicselected=$selected;}

  print qq(
   <div id="search">
   <form method="get" action="$g->{scriptname}">
    Search Criteria:
      <a class="$allselected" href="$g->{scriptname}?type=all&view=$g->{view}">All</a>
      <a class="$humanselected" href="$g->{scriptname}?type=human&view=$g->{view}">Human</a>
      <a class="$nonhumanselected" href="$g->{scriptname}?type=nonhuman&view=$g->{view}">Animal</a>
      <a class="$basicselected" href="$g->{scriptname}?type=basic&view=$g->{view}">Basic Sciences</a>
          <input type="textfield" name="query" value="$g->{query}" size=40>
          <input type="hidden" name="view" value="$g->{view}" override=1>
          <input type="hidden" name="type" value="$g->{type}" override=1>
	      <input type="hidden" name="action" value="query">
	      <input type="submit" value="Search">
   </form>
  );

    print qq(List By Last Names (beginning with):&nbsp;);
    my $alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(my $digit="0"; $digit<26; ++$digit){
      my $letter=substr($alpha,$digit,1);
      if(defined($g->{letter}) and $g->{letter} eq "$letter"){
        print qq(<a href="$g->{scriptname}?action=list&letter=$letter&view=$g->{view}&type=$g->{type}">$letter</a>);
      }
      else{
        print qq(<a href="$g->{scriptname}?action=list&letter=$letter&view=$g->{view}&type=$g->{type}">$letter</a>);
      }
    }
  print "</div><br /> <!-- end search -->\n\n";
}

sub analytics{
  print qq(\n<div id="analytics">\n);
  $total_employees=$g->analytic('Employees','',"*",'','rcs_personnel','');
  my $active_employees=$g->analytic('Employees in Human Studies','',"*",'','rcs_personnel',"where human='true'","percentage:$total_employees");
  my $inactive_employees=$g->analytic('Employees in Animal Studies','',"*",'','rcs_personnel',"where nonhuman='true'","percentage:$total_employees");
  my $suspended_employees=$g->analytic('Employees in Basic Science Studies','',"*",'','rcs_personnel',"where basic='true'","percentage:$total_employees");
  print qq(\n</div> <!-- end analytics -->\n);
}
