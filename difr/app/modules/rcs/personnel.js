<script language="javascript"><!--
$(document).ready(function() {
  $('#page_effect').fadeIn(500);
	$('#tabs').tabs();
  $('#datepicker1').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker2').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker3').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker4').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker5').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker6').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker7').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
  $('#datepicker8').datepicker({ inline: true, dateFormat: 'yy-mm-dd' });
});

function showMe (it, box) {
  var vis = (box.checked) ? "block" : "none";
  document.getElementById(it).style.display = vis;
}
--></script>
