#!/usr/bin/perl
# This process kicks off the chain of scripts that constitute the
# proof of concept.

# 1 - Assign patient to clinic

# 2 - Create appointment (completed)
print "executing appointment scheduing routine...\n";
system("perl appointment-schedule.pl");

# 3 - check-in
print "executing appointment check-in routine...\n";
system("check-in-appointment.pl");

# 4 - See patient, and generate progress note
print "executing progress note creation routine...\n";
system("create-progress-note.pl");

# 5 - check-out (enter encounter data)
print "executing appointment check-out routine...\n";
system("check-out-appointment.pl");

# 6 - Have clinician create outpatient med order 

# 7 - Have pharmacy finish the order (backdoor order entry)

# 8 - Pt label printed ~ considered filled ~ Dispensed to patient

exit;