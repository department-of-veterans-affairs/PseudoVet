<script language="javascript"><!--
  var passwordmessage='minimum 6 characters with letters, numbers, and a special character.';
  var valid=true;
$(document).ready(function() {
  $('#page_effect').fadeIn(500);
  var result= $.countLines("#textarea", {recalculateCharWidth : true});
});

// validate registration form
function validate_form(){
  //valid=true;
  if(document.registration_form.password.value == ""){
    passwordmessage='Password must have at least 6 characters.  ';
    valid=false;
  }
  if(document.registration_form.password.value.search(/\d/)=-1){
    passwordmessage=password + 'Password must have at least one number.  ';
    valid=false;
  }  
  if(valid == false){
    alert(passwordmessage); 
  }
}

--></script>
