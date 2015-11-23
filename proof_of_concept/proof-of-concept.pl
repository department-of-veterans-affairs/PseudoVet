#!/usr/bin/perl
# This process kicks off the chain of scripts that constitute the
# proof of concept.

print "executing appointment scheduing routine...\n";
eval `appointment-schedule.pl`

print "executing appointment check-in routine...\n";
eval `appointment-check-in.pl`

print "executing progress note creation routine...\n";
eval `create-progress-note.pl`

exit;