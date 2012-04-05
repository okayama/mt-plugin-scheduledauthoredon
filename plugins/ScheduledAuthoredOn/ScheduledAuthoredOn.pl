package MT::Plugin::ScheduledAuthoredOn;
use strict;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );
use MT::Util qw( encode_html );

our $PLUGIN_NAME = 'ScheduledAuthoredOn';
our $PLUGIN_VERSION = '1.0';
our $SCHEMA_VERSION = '0.1';

my $plugin = new MT::Plugin::ScheduledAuthoredOn( {
    id => $PLUGIN_NAME,
    key => lc $PLUGIN_NAME,
    name => $PLUGIN_NAME,
    version => $PLUGIN_VERSION,
    schema_version => $SCHEMA_VERSION,
    description => "<__trans phrase='Authored on for scheduled publishing.'>",
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    l10n_class => 'MT::' . $PLUGIN_NAME . '::L10N',
} );
MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        object_types => {
            entry => {
                scheduled_authored_on => 'datetime',
            },
        },
        callbacks => {
            'MT::App::CMS::template_param.edit_entry' => 'MT::' . $PLUGIN_NAME . '::Plugin::_cb_tp_edit_entry',
            'MT::App::CMS::template_param.preview_strip' => 'MT::' . $PLUGIN_NAME . '::Plugin::_cb_tp_preview_strip',
            'cms_post_save.entry' => 'MT::' . $PLUGIN_NAME . '::Plugin::_cb_cms_post_save_entry',
            'cms_post_save.page' => 'MT::' . $PLUGIN_NAME . '::Plugin::_cb_cms_post_save_entry',
            'scheduled_post_published' => 'MT::' . $PLUGIN_NAME . '::Plugin::_cb_scheduled_post_published',
        },
    } );
}

1;
