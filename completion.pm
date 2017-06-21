#!/usr/bin/env perl

use lib ($ENV{RLWRAP_FILTERDIR} or ".");
use RlwrapFilter;
use strict;


my $filter = new RlwrapFilter;
my $name = $filter -> name;

$filter -> help_text("");
$filter -> completion_handler(\&complete);
$filter -> run;

sub users {
    return qx(./passman list user);
}

sub groups {
    return qx(./passman list group);
}
sub passwords {
    return qx(./passman list pass);
}


sub complete {
    my ($line, $prefix, @completions) = @_;

    my @base = ('get','modify',
		'list','info',
		'passwd',
		'help',
		'add','del',
		'manage',
		'promote','demote');

    my @words = split /\s+/, $line;
    my $nwords = scalar @words;
    
    # only count completed words
    $nwords-- if $prefix;
    
    my @result = ();
    if($nwords == 0) {
	@result = @base;

    } else {
	# try to avoid suggesting completions in the middle of a line
	return '' unless grep /$prefix$/, $words[-1];
	my $first = $words[0];

	if($first eq 'passwd') {
	    @result = ();

	} elsif($nwords == 1 
		&& $first eq 'help') {
	    @result = @base;

	} elsif($nwords == 1 
		&& ($first eq 'get' 
		    || $first eq 'modify')) {
	    @result = &passwords;

	} elsif($first eq 'list' 
		|| $first eq 'info' 
		|| $first eq 'add'
		|| $first eq 'del') {
	    if($nwords == 1) {
		@result = ('user','group','pass');

	    } elsif($nwords == 2) {
		my $second = $words[1];
		
		if($second eq 'user') {
		    @result = &users;
		    
		} elsif($second eq 'group') {
		    @result = &groups;
		    
		} elsif($second eq 'pass') {
		    @result = &passwords;
		}
	    }
	} elsif($nwords == 1 
		&& ($first eq 'promote' 
		    || $first eq 'demote')) {
	    @result = &users;

	} elsif($first eq 'manage') {
	    if($nwords == 1) {
		@result = ('user','pass');
		
	    } else {
		my $second = $words[1];
		
		if($nwords == 2) {
		    if($second eq 'user') {
			@result = &users;

		    } elsif($second eq 'pass') {
			@result = &passwords;
			
		    }
		} elsif($nwords == 3) {
		    my @temp = &groups;
		    @result = map { '-' . $_ } @temp;
		    push @result, map { '+' . $_ } @temp;
		}
	    }
	}
    }

    chomp(@result);
    return grep /^$prefix/, @result;
}
