#!/usr/bin/perl

use 5.12.3;
use strict;
use warnings FATAL => 'all';
use File::Copy;
use Tie::File;

chomp (my $pwd = `pwd`);
mkdir "$pwd/SBO" unless -d "$pwd/SBO";
copy ('/home/d4wnr4z0r/sbotwo/sbotools/SBO-Lib/lib/SBO/Lib.pm', "$pwd/SBO");

open my $write, '>>', "$pwd/SBO/Lib.pm";

sub pr ($) {
	my $thing = shift;
	print {$write} "our \$$thing = 1;\n";
}

for my $thing (qw(interactive compat32 no_readme jobs distclean noclean no_install no_reqs force force_reqs)) {
	pr $thing;
}

print {$write} "my \%locations;\n";
print {$write} "my \%options = (nothing => 'to see here');\n";

sub get_subs ($) {
	my $read = shift;
	my $begin_regex = qr/^sub\s+[a-z0-9_]+/;
	my $usage_regex = qr/^sub\s+show_usage/;
	my $end_regex = qr/^}$/;
	my $begin = 0;
	my $end = 0;
	while (my $line = <$read>) {
		if (! $begin) {
			if ($line =~ $begin_regex) {
				if ($line !~ $usage_regex) {
					$end = 0, $begin++, print {$write} $line;
				}
			}
		} elsif (! $end) {
			if ($line =~ $end_regex) {
				$begin = 0, $end++, print {$write} $line;
			} else {
				print {$write} $line;
			}
		}
	}
}

for my $file (qw(sbocheck sboclean sboconfig sbofind sboupgrade)) {
	open my $read, '<', "../$file";
	get_subs $read;
	close $read;
}
close $write;

my @subs;
open my $file_h, '<', "$pwd/SBO/Lib.pm";
my $regex = qr/^sub\s+([^\s]+)\s+/;
while (my $line = <$file_h>) {
	if (my $sub = ($line =~ $regex)[0]) {
		push @subs, $sub;
	}
}

seek $file_h, 0, 0;
my @not_exported;                                                               
FIRST: for my $sub (@subs) {                                                    
	my $found = 'FALSE';                                                        
	my $has = 'FALSE';                                                          
	SECOND: while (my $line = <$file_h>) {
		if ($found eq 'FALSE') {                                                
			$found = 'TRUE', next SECOND if $line =~ /\@EXPORT/;
		} else {                                                                
			last SECOND if $line =~ /^\);$/;                                    
			$has = 'TRUE', last SECOND if $line =~ /$sub/;
		}       
	}   
	push @not_exported, $sub unless $has eq 'TRUE';
	seek $file_h, 0, 0;
}

close $file_h;
tie my @file, 'Tie::File', "$pwd/SBO/Lib.pm";
FIRST: for my $line (@file) {
	if ($line =~ /\@EXPORT/) {
		$line = "our \@EXPORT = qw(". join ' ', @not_exported;
	}
	$line = "#$line" if $line =~ /root privileges/;
}


