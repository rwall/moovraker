#!/usr/bin/perl
# Moovraker!
use strict;
use LWP::UserAgent;
use Data::Dumper;
use JSON;

my @file_extensions = qw(
	m4v
	mkv
	iso
	avi
);
my $file_extension_regex = "\.(:?" . join("|", @file_extensions) . ")";

if (!@ARGV) {
		print_usage();
		exit(1);
}

my @directories = @ARGV;

foreach my $stage_dir (@directories) {
		$stage_dir =~ s/\/$//;
		#print STDERR "Processing $stage_dir\n";
		if (!-d $stage_dir) {
				print STDERR "$stage_dir: invalid directory\n";
				next;
		}
		opendir my($dh), $stage_dir;
		my @dirlist = readdir $dh;
		foreach my $file (@dirlist) {
				$file = "$stage_dir/$file";
				if ($file =~ /\/(:?\.|\.\.)\/?$/) {
						next;
				} elsif (-f $file) {
						next unless $file =~ /$file_extension_regex$/;
						print STDERR "Process file $file in dir $stage_dir\n";
						my $f = $file;
						$f =~ s/$stage_dir\/?//;
						process_file($f);
				} elsif (-d $file) {
						push(@directories, "$file");
				}
		}
}




sub process_file {
		my $filename = shift;
		$filename =~ s/![\w\s]//;
		$filename =~ s/$file_extension_regex$//;
		print STDERR "scrubbed filename: $filename\n";
		my $base_url = 'http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q='; 
		my $request_url = $base_url . $filename;
		my $ua = new LWP::UserAgent;
		my $response = $ua->get($request_url);
		my $j = JSON->new->allow_nonref->utf8->relaxed->decode($response->content);
		#	print Dumper($j);
		if (defined $j->{title_popular}) {
				print "TITLE: $j->{title_popular}->[0]->{'title'}\n";
		}
}


sub print_usage {
		select STDERR;
		print "$0 <staging directory ..>\n";
}


