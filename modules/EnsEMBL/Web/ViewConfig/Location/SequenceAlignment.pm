=head1 LICENSE

Copyright [2009-2014] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

# $Id: SequenceAlignment.pm,v 1.2 2013-11-29 08:53:21 nl2 Exp $

package EnsEMBL::Web::ViewConfig::Location::SequenceAlignment;

use strict;

use EnsEMBL::Web::Constants;

sub form {
  my $self       = shift;
  my $sp         = $self->species;
  my $variations = $self->species_defs->databases->{'DATABASE_VARIATION'} || {};
  my $strains    = $self->species_defs->translate('strain');
  my $ref        = $variations->{'REFERENCE_STRAIN'};
  
  my %general_markup_options = EnsEMBL::Web::Constants::GENERAL_MARKUP_OPTIONS; # shared with compara_markup and marked-up sequence
  my %other_markup_options   = EnsEMBL::Web::Constants::OTHER_MARKUP_OPTIONS;   # shared with compara_markup
  
  push @{$general_markup_options{'exon_ori'}{'values'}}, { value => 'off', caption => 'None' };
  $general_markup_options{'exon_ori'}{'label'} = 'Exons to highlight';
  
  $self->add_form_element($other_markup_options{'display_width'});
  $self->add_form_element($other_markup_options{'strand'});
  $self->add_form_element($general_markup_options{'exon_ori'});

  $self->add_form_element({
    type   => 'DropDown', 
    select => 'select',   
    name   => 'match_display',
    label  => 'Matching basepairs',
    values => [
      { value => 'off', caption => 'Show all' },
      { value => 'dot', caption => 'Replace matching bp with dots' }
    ]
  });
  
  $self->variation_options({ consequence => 'no', label => 'Highlight resequencing differences' }) if $variations;
  $self->add_form_element($general_markup_options{'line_numbering'});
  $self->add_form_element($other_markup_options{'codons_display'});
  $self->add_form_element($other_markup_options{'title_display'});
  
  if ($ref) {
    $self->add_form_element({
      type  => 'NoEdit',
      name  => 'reference_sample',
      label => "Reference $strains",
      value => $ref
    });
  }
  
  $strains .= 's';

  my $fs = $self->add_fieldset("Resequenced $strains"); ## VB
  
  foreach (sort (@{$variations->{'DEFAULT_STRAINS'} || []}, @{$variations->{'DISPLAY_STRAINS'} || []})) {
    next if $_ eq $ref;
    
    ## VB - bypass add_form_element for performance
    $fs->add_field({ 
      type  => 'CheckBox', 
      label => $_,
      name  => $_,
      value => 'yes', 
      raw   => 1,
      checked => $self->get($_) eq 'yes' ? 1 : 0
    });
    $self->{'labels'}{$_} ||= $_;
    ## VB
    
  } 
}

1;
