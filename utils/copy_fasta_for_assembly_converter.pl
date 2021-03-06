use 5.10.1;
use strict;
use warnings;
use File::Find  qw(find);
use File::Slurp qw(read_dir);
use File::Copy  qw(copy);

# helper script to copy FASTA files for assembly converter

my $fasta_path = $ARGV[0];
my $ac_path    = $ARGV[1];

die "Usage: $0 <source-fasta-path> <dest-ac-path>\n" unless $fasta_path and $ac_path;
die "Cannot find fasta dir: $fasta_path\n" unless -d $fasta_path;
die "Cannot find AC dir: $ac_path\n" unless -d $ac_path;

my @fasta_dirs = sort(grep {$_ ne 'bacteria'} read_dir($fasta_path));
my @ac_dirs    = sort(read_dir($ac_path));

foreach my $ac_dir (@ac_dirs) {

  my $copy_matches = sub{
    return unless /$ac_dir\..*\.dna\.toplevel\.fa$/i;
    say "copying $File::Find::name --> $ac_path/$ac_dir";
    copy($File::Find::name, "$ac_path/$ac_dir") || die $!;
  };
  
  find($copy_matches, "$fasta_path/$_") for @fasta_dirs;
}