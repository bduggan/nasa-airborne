#!/usr/bin/env perl

use Mojo::DOM;
use v5.14;
use Data::Dumper;

# https://airbornescience.nasa.gov/instrument/all?page=1

my $dom = Mojo::DOM->new(join '', <>);
my @all;

$dom->find('tr')->each(
  sub {
    my $title = $_->at('.views-field-title a')->text;
    next if $title eq 'Title';

    my %this = (
      title => $title,
      url   => $_->at('.views-field-title a')->attr('href'),
      id    => $_->at('.views-field-entity-id')->text,
      aircraft => [$_->find('.views-field-field-aircraft > a')->map('text')->map(sub{s/ /_/gr;})->each],
      type => $_->find('.views-field-field-itype > a')->compact->map('text')->join(', ')->to_string
    );

    push @all, \%this;
  }
);

say Dumper(\@all);

