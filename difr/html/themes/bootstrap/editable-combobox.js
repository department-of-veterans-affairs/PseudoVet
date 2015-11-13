<script language="JavaScript"> //Common functions for all dropdowns

  /*----------------------------------------------
  The Common functions used for all dropdowns are:
  -----------------------------------------------

  -- function FindKeyCode(e)
  -- function FindKeyChar(e)
  -- function fnLeftToRight(getdropdown)
  -- function fnRightToLeft(getdropdown)

  --------------------------- Subrata Chakrabarty */

  function fnLeftToRight(getdropdown)
  {
    getdropdown.style.direction = "ltr";
  }

  function fnRightToLeft(getdropdown)
  {
    getdropdown.style.direction = "rtl";
  }


  /*
  Since Internet Explorer and NetscapeFirefoxChrome have different
  ways of returning the key code, displaying keys
  browser-independently is a bit harder.
  However, you can create a script that displays keys
  for either browser.
  The following function will display each key
  in the status line:

  The "FindKey.." function receives the "event" object
  from the event handler and stores it in the variable "e".
  It checks whether the "e.which" property exists (for NetscapeFirefoxChrome),
  and stores it in the "keycode" variable if present.
  Otherwise, it assumes the browser is Internet Explorer
  and assigns to keycode the "e.keyCode" property.
  */

  function FindKeyCode(e)
  {
    if(e.which)
    {
    keycode=e.which;  //NetscapeFirefoxChrome
    }
    else
    {
    keycode=e.keyCode; //Internet Explorer
    }

    //alert("FindKeyCode"+ keycode);
    return keycode;
  }

  function FindKeyChar(e)
  {
    keycode = FindKeyCode(e);
    if((keycode==8)||(keycode==127))
    {
    character="backspace"
    }
    else if((keycode==46))
    {
    character="delete"
    }
    else
    {
    character=String.fromCharCode(keycode);
    }
    //alert("FindKey"+ character);
    return character;
  }

</script>

<script language="JavaScript"> //Dropdown specific functions, which manipulate dropdown specific global variables

  /*----------------------------------------------
  Dropdown specific global variables are:
  -----------------------------------------------
  1) vEditableOptionIndex_A   --> this needs to be set by Programmer!! See explanation.
  2) vEditableOptionText_A    --> this needs to be set by Programmer!! See explanation.
  3) vPreviousSelectIndex_A
  4) vSelectIndex_A
  5) vSelectChange_A

  --------------------------- Subrata Chakrabarty */

  /*----------------------------------------------
  Dropdown specific functions
  (which manipulate dropdown specific global variables)
  -----------------------------------------------
  1) function fnChangeHandler_A(getdropdown)
  2) function fnKeyPressHandler_A(getdropdown, e)
  3) function fnKeyUpHandler_A(getdropdown, e)
  4) function fnKeyDownHandler_A(getdropdown, e)

  --------------------------- Subrata Chakrabarty */

  /*------------------------------------------------
  IMPORTANT: Global Variable required to be SET by programmer
  -------------------------- Subrata Chakrabarty  */

  var vEditableOptionIndex_A = 0;

  // Give Index of Editable option in the dropdown.
  // For eg.
  // if first option is editable then vEditableOptionIndex_A = 0;
  // if second option is editable then vEditableOptionIndex_A = 1;
  // if third option is editable then vEditableOptionIndex_A = 2;
  // if last option is editable then vEditableOptionIndex_A = (length of dropdown - 1).
  // Note: the value of vEditableOptionIndex_A cannot be greater than (length of dropdown - 1)

  var vEditableOptionText_A = "--?--";

  // Give the default text of the Editable option in the dropdown.
  // For eg.
  // if the editable option is <option ...>--?--</option>,
  // then set vEditableOptionText_A = "--?--";

  /*------------------------------------------------
  Global Variables required for
  fnChangeHandler_A(), fnKeyPressHandler_A() and fnKeyUpHandler_A()
  for Editable Dropdowns
  -------------------------- Subrata Chakrabarty  */

  var vPreviousSelectIndex_A = 0;
  // Contains the Previously Selected Index, set to 0 by default

  var vSelectIndex_A = 0;
  // Contains the Currently Selected Index, set to 0 by default

  var vSelectChange_A = 'MANUAL_CLICK';
  // Indicates whether Change in dropdown selected option
  // was due to a Manual Click
  // or due to System properties of dropdown.

  // vSelectChange_A = 'MANUAL_CLICK' indicates that
  // the jump to a non-editable option in the dropdown was due
  // to a Manual click (i.e.,changed on purpose by user).

  // vSelectChange_A = 'AUTO_SYSTEM' indicates that
  // the jump to a non-editable option was due to System properties of dropdown
  // (i.e.,user did not change the option in the dropdown;
  // instead an automatic jump happened due to inbuilt
  // dropdown properties of browser on typing of a character )

  /*------------------------------------------------
  Functions required for  Editable Dropdowns
  -------------------------- Subrata Chakrabarty  */

  function fnSanityCheck_A(getdropdown)
  {
    if(vEditableOptionIndex_A>(getdropdown.options.length-1))
    {
    alert("PROGRAMMING ERROR: The value of variable vEditableOptionIndex_... cannot be greater than (length of dropdown - 1)");
    return false;
    }
  }

  function fnKeyDownHandler_A(getdropdown, e)
  {
    fnSanityCheck_A(getdropdown);

    // Press [ <- ] and [ -> ] arrow keys on the keyboard to change alignment/flow.
    // ...go to Start : Press  [ <- ] Arrow Key
    // ...go to End : Press [ -> ] Arrow Key
    // (this is useful when the edited-text content exceeds the ListBox-fixed-width)
    // This works best on Internet Explorer, and not on NetscapeFirefoxChrome

    var vEventKeyCode = FindKeyCode(e);

    // Press left/right arrow keys
    if(vEventKeyCode == 37)
    {
      fnLeftToRight(getdropdown);
    }
    if(vEventKeyCode == 39)
    {
      fnRightToLeft(getdropdown);
    }

    // Delete key pressed
    if(vEventKeyCode == 46)
    {
      if(getdropdown.options.length != 0)
      // if dropdown is not empty
      {
        if (getdropdown.options.selectedIndex == vEditableOptionIndex_A)
        // if option is the Editable field
        {
          getdropdown.options[getdropdown.options.selectedIndex].text = '';
          getdropdown.options[getdropdown.options.selectedIndex].value = '';
        }
      }
    }

    // backspace key pressed
    if(vEventKeyCode == 8 || vEventKeyCode == 127)
    {
      if(getdropdown.options.length != 0)
      // if dropdown is not empty
      {
        if (getdropdown.options.selectedIndex == vEditableOptionIndex_A)
        // if option is the Editable field
        {
           // make Editable option Null if it is being edited for the first time
           if ((getdropdown[vEditableOptionIndex_A].text == vEditableOptionText_A)||(getdropdown[vEditableOptionIndex_A].value == vEditableOptionText_A))
           {
             getdropdown.options[getdropdown.options.selectedIndex].text = '';
             getdropdown.options[getdropdown.options.selectedIndex].value = '';
           }
           else
           {
             getdropdown.options[getdropdown.options.selectedIndex].text = getdropdown.options[getdropdown.options.selectedIndex].text.slice(0,-1);
             getdropdown.options[getdropdown.options.selectedIndex].value = getdropdown.options[getdropdown.options.selectedIndex].value.slice(0,-1);
           }
        }
      }
      if(e.which) //NetscapeFirefoxChrome
      {
        e.which = '';
      }
      else //Internet Explorer
      {
        e.keyCode = '';
      }
      if (e.cancelBubble)	  //Internet Explorer
      {
        e.cancelBubble = true;
        e.returnValue = false;
      }
      if (e.stopPropagation)	 //NetscapeFirefoxChrome
      {
          e.stopPropagation();
      }
      if (e.preventDefault)	 //NetscapeFirefoxChrome
      {
      	e.preventDefault();
      }
    }
  }

  function fnChangeHandler_A(getdropdown)
  {
    fnSanityCheck_A(getdropdown);

    vPreviousSelectIndex_A = vSelectIndex_A;
    // Contains the Previously Selected Index

    vSelectIndex_A = getdropdown.options.selectedIndex;
    // Contains the Currently Selected Index

    if ((vPreviousSelectIndex_A == (vEditableOptionIndex_A)) && (vSelectIndex_A != (vEditableOptionIndex_A))&&(vSelectChange_A != 'MANUAL_CLICK'))
    // To Set value of Index variables - Subrata Chakrabarty
    {
      getdropdown[(vEditableOptionIndex_A)].selected=true;
      vPreviousSelectIndex_A = vSelectIndex_A;
      vSelectIndex_A = getdropdown.options.selectedIndex;
      vSelectChange_A = 'MANUAL_CLICK';
      // Indicates that the Change in dropdown selected
      // option was due to a Manual Click
    }
  }

  function fnKeyPressHandler_A(getdropdown, e)
  {
    fnSanityCheck_A(getdropdown);

    keycode = FindKeyCode(e);
    keychar = FindKeyChar(e);

    // Check for allowable Characters
    // The various characters allowable for entry into Editable option..
    // may be customized by minor modifications in the code (if condition below)
    // (you need to know the keycode/ASCII value of the  character to be allowed/disallowed.
    // - Subrata Chakrabarty

    if ((keycode>47 && keycode<59)||(keycode>62 && keycode<127) ||(keycode==32))
    {
      var vAllowableCharacter = "yes";
    }
    else
    {
      var vAllowableCharacter = "no";
    }

    //alert(window); alert(window.event);

    if(getdropdown.options.length != 0)
    // if dropdown is not empty
      if (getdropdown.options.selectedIndex == (vEditableOptionIndex_A))
      // if selected option the Editable option of the dropdown
      {

        // Empty space (ascii 32)  is not captured by NetscapeFirefoxChrome when .text is used
        // NetscapeFirefoxChrome removes extra spaces at end of string when .text is used
        // NetscapeFirefoxChrome allows one empty space at end of string when .value is used
        // Hence, use .value insead of .text
        var vEditString = getdropdown[vEditableOptionIndex_A].value;

        // make Editable option Null if it is being edited for the first time
        if(vAllowableCharacter == "yes")
        {
          if ((getdropdown[vEditableOptionIndex_A].text == vEditableOptionText_A)||(getdropdown[vEditableOptionIndex_A].value == vEditableOptionText_A))
            vEditString = "";
        }

        if (vAllowableCharacter == "yes")
        // To handle addition of a character - Subrata Chakrabarty
        {
          vEditString+=String.fromCharCode(keycode);
          // Concatenate Enter character to Editable string

          // The following portion handles the "automatic Jump" bug
          // The "automatic Jump" bug (Description):
          //   If a alphabet is entered (while editing)
          //   ...which is contained as a first character in one of the read-only options
          //   ..the focus automatically "jumps" to the read-only option
          //   (-- this is a common property of normal dropdowns
          //    ..but..is undesirable while editing).

          var i=0;
          var vEnteredChar = String.fromCharCode(keycode);
          var vUpperCaseEnteredChar = vEnteredChar;
          var vLowerCaseEnteredChar = vEnteredChar;


          if(((keycode)>=97)&&((keycode)<=122))
          // if vEnteredChar lowercase
            vUpperCaseEnteredChar = String.fromCharCode(keycode - 32);
            // This is UpperCase


          if(((keycode)>=65)&&((keycode)<=90))
          // if vEnteredChar is UpperCase
            vLowerCaseEnteredChar = String.fromCharCode(keycode + 32);
            // This is lowercase

          if(e.which) //For NetscapeFirefoxChrome
          {
            // Compare the typed character (into the editable option)
            // with the first character of all the other
            // options (non-editable).

            // To note if the jump to the non-editable option was due
            // to a Manual click (i.e.,changed on purpose by user)
            // or due to System properties of dropdown
            // (i.e.,user did not change the option in the dropdown;
            // instead an automatic jump happened due to inbuilt
            // dropdown properties of browser on typing of a character )

            for (i=0;i<=(getdropdown.options.length-1);i++)
            {
              if(i!=vEditableOptionIndex_A)
              {
                var vReadOnlyString = getdropdown[i].value;
                var vFirstChar = vReadOnlyString.substring(0,1);
                if((vFirstChar == vUpperCaseEnteredChar)||(vFirstChar == vLowerCaseEnteredChar))
                {
                  vSelectChange_A = 'AUTO_SYSTEM';
                  // Indicates that the Change in dropdown selected
                  // option was due to System properties of dropdown
                  break;
                }
                else
                {
                  vSelectChange_A = 'MANUAL_CLICK';
                  // Indicates that the Change in dropdown selected
                  // option was due to a Manual Click
                }
              }
            }
          }
        }

        // Set the new edited string into the Editable option
        getdropdown.options[vEditableOptionIndex_A].text = vEditString;
        getdropdown.options[vEditableOptionIndex_A].value = vEditString;

        return false;
      }
    return true;
  }

  function fnKeyUpHandler_A(getdropdown, e)
  {
    fnSanityCheck_A(getdropdown);

    if(e.which) // NetscapeFirefoxChrome
    {
      if(vSelectChange_A == 'AUTO_SYSTEM')
      {
        // if editable dropdown option jumped while editing
        // (due to typing of a character which is the first character of some other option)
        // then go back to the editable option.
        getdropdown[(vEditableOptionIndex_A)].selected=true;
      }

      var vEventKeyCode = FindKeyCode(e);
      // if [ <- ] or [ -> ] arrow keys are pressed, select the editable option
      if((vEventKeyCode == 37)||(vEventKeyCode == 39))
      {
        getdropdown[vEditableOptionIndex_A].selected=true;
      }
    }
  }

/*-------------------------------------------------------------------------------------------- Subrata Chakrabarty */

</script>  <!--end of script for dropdown lstDropDown_A -->
