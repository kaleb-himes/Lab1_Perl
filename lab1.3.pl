######################################### 	
#    CSCI 305 - Programming Lab #1		
#										
#  < Kaleb >			
#  < kaleb.himes@gmail.com >			
#										
#########################################
use strict;
use Data::Dump;
# Replace the string value of the following variable with your names.

#This is the program we talked with you extensively about, it goes for much
#quicker storage but then the trade-off is slow look up when generating the song
#titles. Worst case (generating 20 word titles) always occurs at 28 seconds +/- 1 second

my $name = "<Kaleb>";
my $partner = "<Michael>";
print "CSCI 305 Lab 1 submitted by $name and $partner.\n\n";
# Opens the file and assign it to handle FILE
open (FILE, 'unique_tracks.txt');

my @values = ();
#a counter that will keep track of the unique number of song titles found
my $counter = 0;
while (<FILE>) {
chomp;
     my ($Tag1, $Tag2, $Artist, $cutTitle) = split("<SEP>");
	 $cutTitle = "zzzzzzzzzzzzzzz" if $cutTitle =~ s/[^[:ascii:]]//g;
     $cutTitle =~ s/[\[\(\{\\\/\+\*=:\`"-].*$//g;
     $cutTitle =~ s/[-\?!\.;&\$¿¡\@%#\|\*_]//g;
     $cutTitle = lc $cutTitle;
	 $cutTitle =~ s/feat.*$//g;
     push(@values, $cutTitle)&&$counter++ if $cutTitle!~"zzzzzzzzzzzzzzz";
}
close (FILE);

open (MYFILE, '> output.txt');
foreach(@values) {
    print MYFILE $_."\n";
}
close(MYFILE);
print "$counter = the number of Titles found\n";
# At this point (hopefully) you will have finished processing the song 
# title file and have populated your data structure of bigram counts.
print "File parsed. Bigram model built.\n";



# User control loop
my %count;
my $word1;
my $word2 = "";
open (FILE, 'output.txt');
while(<FILE>) {
	chomp;
	foreach $word1 (split," ") {
		my $bigram = "$word2 $word1";
		$word2 = $word1;
		$count{$bigram}++;
	}
}
close(FILE);
my $maxRuns = 0;
#the last bigram is the greatest occuring
my $last = '';
$counter = 0;
#the user input word to match
my $some_word = '';
#a variable used if no stop word is encountered
my $noStop = '';
my @titles = ();
my @troubleWords= ();
@troubleWords = ('a','an','and', 'are','by','for','from','in','of','on','or','out','the','to','with');
my @generatedTitle = ();
do{
	@titles = (); #clear the array upon each call of the do-while loop
	
	#if this is the first run of the do-while ask for a word from user
	if($maxRuns == 0){
		
		$some_word = '';
		#ask for new input from user
		print("\n\nEnter Word (or 'q' to quit): ");
		$some_word = <STDIN>;
		chomp($some_word);
		if($some_word eq "q"){
			print("\n\nGoodbye\n\n");
			exit 0;
		}
	
	}
	my @titles = (grep /\b\Q$some_word \E\b/, sort numerically keys %count);
	$counter = @titles;
	#increase number of words to generate by 1
	$maxRuns++;
	
	#limit cycles max 20 && some titles were found
	if($maxRuns <= 20 && $counter > 0){
		#pop the last spot in the array, send to mcw for trimming
		$last = pop @titles;
		
		#uncomment below for a recursive method to always generate 20 word song titles
		#and comment out the following foreach loop
		 $noStop = stopWords(\@titles,\@troubleWords,$last);
		
		#this was the method used prior to generating 20 word song titles for each search
		#this method would generally terminate after only 2 or 3 word long song titles if using
		#english words.
#			my $check = (split " ", $last)[-1];
#			foreach my $stop(@stopWords) {
#				my $compare = $stop eq $check;
#				if($compare == 1){
#					$last = '.';
#					$noStop = '.';
#					$maxRuns = 0;
#				}else{
#				$noStop = $last;
#				}	
#			}
		
		#set counter to zero
		$counter = 0;
		#run sub mcw--> return the most frequent
		#use the most frequent as the argument in do-while loop limit 20
		$some_word = mcw($noStop, $maxRuns);
		chomp($some_word);
		push(@troubleWords, $some_word);
	}else{
		#otherwise reset max runs to zero
		print("\n\"@generatedTitle\"\n");
		@generatedTitle = ();
		$maxRuns = 0;
	}
	
}while($some_word ne "q");
print ("\n\ngoodbye");
exit 0;

sub mcw{
	#Param: reference to sorted bigram to use for lookup
	my $Arg1 = shift @_;
	my $max = shift @_;
	if($Arg1 eq ''){
		$max = 0;
	}
	my $uniqueCommon = (split(/ /, $Arg1))[-1];
	print("\"$uniqueCommon\"\n");
	push(@generatedTitle, $uniqueCommon);
	return $uniqueCommon;
	
}
# a recursive method for finding non-repeating words to create the song title from
 sub stopWords{
	 my ($foundBiGrams,$stops,$theArgument) = @_;
	 chomp($theArgument);
	 my $length = @$stops;
	 my $checkArg = '';
	 $checkArg = (split(/ /, $theArgument))[-1];
	 #print("the word being checked is: \"$checkArg\"\n");
		 for my $stop(0..$length){
			 if(@$stops[$stop] eq $checkArg){
			 #we were not taught enough about perl to understand why this is behaving the way it is.
			 #somehow it is not resetting each time and starting over from the beginning of the array
			 #as my logic is telling me it should so i reset $stop multiple times but still is not resetting.
				$stop = 0;
				$checkArg = '';
				$theArgument = '';
				$theArgument = pop @$foundBiGrams;
				#print("the title being checked is: \"$theArgument\"\n");
				stopWords($foundBiGrams,$stops,$theArgument);				
			 }
		 }
	#print("the value being pushed into the array is: \"$checkArg\"\n");
	#if the checkArgument passed the test and made it this far, push it into the stopWords
	#array so that it will not be repeated later in the song title.
	return $theArgument;
 }

foreach my $bigram (sort numerically keys %count) {
	#print "$count{$bigram}\t$bigram\n";
}

sub numerically { # compare two words numerically
	#$count{$b} <=> $count{$a}; # decreasing order
	 $count{$a} <=> $count{$b}; # increasing order
}