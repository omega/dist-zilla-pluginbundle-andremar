package Dist::Zilla::PluginBundle::ANDREMAR;
# ABSTRACT: BeLike::ANDREMAR when you build your dists
#
use Moose;
use Moose::Autobox;

use Dist::Zilla 4;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Git;

sub configure {
    my ($self) = @_;
    my $name = $self->payload->{name};

    $self->add_plugins(qw/
        Git::GatherDir
        CheckPrereqsIndexed
        CheckExtraTests
        /);


    $self->add_bundle('@Filter', {
            '-bundle' => '@Basic',
            '-remove' => [qw/GatherDir/]
        });

    $self->add_plugins(
        [ 'AutoPrereqs', {
                extra_scanners => [qw/MooseXDeclare/],
                %{ $self->config_slice( { prereq_skip => 'skip' } ), }
            }
        ]
    );

    $self->add_plugins(qw(
        PkgVersion
        MetaConfig
        MetaJSON
        NextRelease
        PodSyntaxTests
        PodCoverageTests
        Repository
        Test::ChangesHasContent
        Test::Compile
        ReportVersions::Tiny
        ContributorsFromGit
        ));

    $self->add_plugins(
        [ Prereqs => 'TestMoreWithSubtests' => {
                -phase => 'test',
                -type => 'requires',
                'Test::More' => '0.96'
            } ],
    );

    $self->add_plugins([
            PodWeaver => { config_plugin => '@ANDREMAR' }
        ]);

    $self->add_bundle('@Git' => {
            tag_format => lc($name) . '-%v',
            push_to => [ qw(origin) ],
        });
    $self->add_plugins(
        [ 'Git::NextVersion' => {
                version_regexp => '^(?:' . $name . '|' . lc($name). ')-(.+)$'
            }]
    );

    $self->add_plugins(
        [ GithubMeta => {
                'user' => 'omega',
                'remote' => [ qw(github origin omega) ],
                issues => 1,
            }
        ]
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

