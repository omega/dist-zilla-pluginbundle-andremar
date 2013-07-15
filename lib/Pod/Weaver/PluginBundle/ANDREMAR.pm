use strict;
use warnings;

package Pod::Weaver::PluginBundle::ANDREMAR;
# ABSTRACT: ANDREMAR and his weaving, based on RJBS
#
use Moo;

extends 'Pod::Weaver::PluginBundle::RJBS';

use Pod::Weaver::Config::Assembler;
use Pod::Weaver::Section::Contributors 0.001 ();

sub _exp { Pod::Weaver::Config::Assembler->expand_package( $_[0] ) }

around 'mvp_bundle_config' => sub {
    my $orig = shift;
    my @plugins = $orig->();

    unshift(@plugins, [ '@ANDREMAR/Encoding', _exp('-Encoding'), {} ]);

    my $i = 0;
    use Data::Dump;
    for (0..scalar(@plugins)) {
        last if $plugins[$i]->[0] =~ m/Authors/;
        $i++;
    }

    Data::Dump::dump $plugins[$i];

    splice(@plugins, $i+1, 0, [ 'Contributors', _exp('Contributors'), {} ],);


    return @plugins;
};





1;

