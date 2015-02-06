#!/usr/bin/env perl

use Mojo::DOM;
use v5.14;
use Data::Dumper;

#https://airbornescience.nasa.gov/aircraft

my $dom = Mojo::DOM->new(join '', <>);
my @all;

$dom->find('.view-content > div ')->each(
  sub {
    my $funder = $_->at('h3')->text;

    $_->find('ul > li ')->each(
      sub {
            my ($i) = $_->find('div > span > a')
            ->map( sub {
                {name => $_->text, url => $_->attr('href'), funder => $funder};
              }
            )->each;

            my ($j) = $_->find('div > div > a > img')
              ->map(sub { {thumbnail => $_->attr('src')} })
              ->each;

            push @all, {%$i,%$j};
        }
    );
  }
);

say Dumper(\@all);

