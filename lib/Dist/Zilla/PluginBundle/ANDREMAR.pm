package Dist::Zilla::PluginBundle::ANDREMAR;
# ABSTRACT: BeLike::ANDREMAR when you build your dists
#
use Moose;
use Moose::Autobox;

use Dist::Zilla 4;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Git;

for my $field (qw/test_synopsis test_pod skip_cpan/) {
    has $field => (
        is => 'ro', isa => 'Bool', lazy => 1,
        default => sub { $_[0]->payload->{$field} // 1 },
    );
}

has 'skip_files' => (
    is => 'ro', isa => 'Str', lazy => 1,
    default => sub { $_[0]->payload->{skip_files} // '' },
);




sub configure {
    my ($self) = @_;
    my $name = $self->payload->{name};

    $self->add_plugins(qw/
        Git::GatherDir
        CheckPrereqsIndexed
        CheckExtraTests
        /);


    my @removed_plugins = qw(GatherDir);

    if ($self->skip_cpan) {
        push @removed_plugins, 'UploadToCPAN';
    }

    $self->add_bundle('@Filter', {
            '-bundle' => '@Basic',
            '-remove' => [@removed_plugins]
        });

    $self->add_plugins(
        [ 'AutoPrereqs', {
                #extra_scanners => [qw/MooseXDeclare/],
                finder => '@ANDREMAR/OurFiles',
                %{ $self->config_slice( { prereq_skip => 'skip' } ), }
            }
        ]
    );

    $self->add_plugins(qw(
        MetaConfig
        MetaJSON
        NextRelease
        Test::ChangesHasContent
        Test::Compile
        Test::CPAN::Changes
        Test::ReportPrereqs
        ContributorsFromGit
        )
    );
    if ($self->test_pod) {
        $self->add_plugins(qw(
            PodSyntaxTests
            PodCoverageTests
            )
        );
    }


    if ($self->skip_files) {
        $self->add_plugins(
            [ 'FileFinder::Filter' => 'OurFiles' => {
                    finder => ':InstallModules',
                    skip => $self->skip_files,
                }
            ],
        );
    } else {
        $self->add_plugins(
            [ 'FileFinder::Filter' => 'OurFiles' => {
                    finder => ':InstallModules',
                }
            ]
        );
    }
    $self->add_plugins(
        [ 'PkgVersion' => {
                finder => '@ANDREMAR/OurFiles',
            }
        ]
    );

    $self->add_plugins(qw(
        Test::Synopsis
        )) if $self->test_synopsis;

    $self->add_plugins(
        [ Prereqs => 'TestMoreWithSubtests' => {
                -phase => 'test',
                -type => 'requires',
                'Test::More' => '0.96',
            } ],
    );

    $self->add_plugins([
            PodWeaver => {
                finder => '@ANDREMAR/OurFiles',
                config_plugin => '@ANDREMAR'
            }
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

