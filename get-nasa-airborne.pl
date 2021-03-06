#!/usr/bin/env perl

use Mojo::UserAgent;
use Data::Dumper;
use YAML::XS qw/Dump/;
use v5.14;

my $base = 'https://airbornescience.nasa.gov';

my $ua = Mojo::UserAgent->new();

my $tx = $ua->get("$base/aircraft");
my $res = $tx->success or die Dumper($tx->error);
my @aircraft;

$res->dom->find('.view-content > div ')->each(
  sub {
    my $funder = $_->at('h3')->text;

    $_->find('ul > li ')->each(
      sub {
            my ($i) = $_->find('div > span > a')
            ->map( sub {
                {name => $_->text, url => $base.$_->attr('href'), funder => $funder};
              }
            )->each;

            my ($j) = $_->find('div > div > a > img')
              ->map(sub { {thumbnail => ($_->attr('src') =~ s/\?.*$//r) } })
              ->each;

            push @aircraft, {%$i,%$j};
        }
    );
  }
);

my @instruments;
my $page = 0;
my $more = 1;
while ($more) {
    $more = 0;
    sleep 1;
    warn "getting page $page\n";
    my $url = "https://airbornescience.nasa.gov/instrument/all";
    $url .= "?page=$page" if $page;
    my $tx = $ua->get($url);
    my $res = $tx->success or die Dumper($tx->error);
    my $dom = $res->dom;

    $dom->find('tr')->each(
      sub {
        my $title = $_->at('.views-field-title a')->text;
        next if $title eq 'Title';
        $more = 1;
        my %this = (
          title => $title,
          url   => $base.$_->at('.views-field-title a')->attr('href'),
          id    => $_->at('.views-field-entity-id')->text,
          aircraft => [$_->find('.views-field-field-aircraft > a')->map('text')->map(sub{s/ /_/gr;})->each],
          type => $_->find('.views-field-field-itype > a')->compact->map('text')->join(', ')->to_string
        );
        push @instruments, \%this;
      }
    );
} continue {
    $page++;
}

say Dump({ aircraft => \@aircraft, instruments => \@instruments});

