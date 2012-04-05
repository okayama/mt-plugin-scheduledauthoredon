package MT::ScheduledAuthoredOn::Plugin;
use strict;

use MT::Util qw( offset_time_list );

my $plugin = MT->component( 'ScheduledAuthoredOn' );

sub _cb_tp_preview_strip {
    my ( $cb, $app, $param, $tmpl ) = @_;
    for my $key ( $app->param ) {
        if ( $key =~ /^scheduled_authored_on/ ) {
            my $input = {
                'data_name' => $key,
                'data_value' => $app->param( $key ),
            };
            push( @{ $param->{ 'entry_loop' } }, $input );
        }
    }
}

sub _cb_cms_post_save_entry {
    my ( $cb, $app, $obj, $original ) = @_;
    my $date = $app->param( 'scheduled_authored_on_date' ) || '';
    my $time = $app->param( 'scheduled_authored_on_time' ) || '';
    if ( my $datetime = $date . $time ) {
        $datetime =~ s/\D//g;
        $obj->scheduled_authored_on( $datetime );
        $obj->save or die $obj->errstr;
    }
}

sub _cb_scheduled_post_published {
    my ( $cb, $mt, $obj ) = @_;
    if ( my $scheduled_authored_on = $obj->scheduled_authored_on ) {
        $obj->authored_on( $scheduled_authored_on );
        $obj->save or die $obj->errstr;
    }
}

sub _cb_tp_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    if ( my $blog = $app->blog ) {
        my $blog_id = $blog->id;
        if ( my $pointer_field = $tmpl->getElementById( 'authored_on' ) ) {
            my $nodeset = $tmpl->createElement( 'app:setting', { id => 'scheduled_authored_on',
                                                                 label => $plugin->translate( 'Scheduled authored on' ),
                                                                 label_class => 'top_level',
                                                                 required => 0,
                                                               }
                                              );
            my $innerHTML = <<'MTML';
<div class="date-time-fields">
    <input type="text" id="scheduled_authored_on" class="text date text-date" name="scheduled_authored_on_date" value="<$mt:var name="scheduled_authored_on_date" escape="html"$>" /> @ <input type="text" class="post-time" name="scheduled_authored_on_time" value="<$mt:var name="scheduled_authored_on_time" escape="html"$>" />
</div>
<mt:setvarblock name="jq_js_include" append="1">
    jQuery().ready( function() {
        jQuery( '#status' ).change( function() {
            selected_value = this.value;
            toggle_scheduled_authored_on( selected_value );
        } );
    } );
    function toggle_scheduled_authored_on( status_value ) {
        if ( status_value == 4 ) {
            getByID( 'scheduled_authored_on-field' ).style.display = 'block';
        } else {
            getByID( 'scheduled_authored_on-field' ).style.display = 'none';
        }
    }
    selected_status = getByID( 'status' ).value;
    toggle_scheduled_authored_on( selected_status );
</mt:setvarblock>
MTML
            $nodeset->innerHTML( $innerHTML );
            $tmpl->insertAfter( $nodeset, $pointer_field );
            my $set_scheduled_authored_on = 0;
            if ( my $entry_id = $app->param( 'id' ) ) {
                my $entry = MT->model( 'entry' )->load( { id => $entry_id, },
                                                        { no_class => 1, }
                                                      );
                if ( $entry ) {
                    if ( my $scheduled_authored_on = $entry->scheduled_authored_on() ) {
                        my $year = substr( $scheduled_authored_on, 0, 4 );
                        my $month = substr( $scheduled_authored_on, 4, 2 );
                        my $day = substr( $scheduled_authored_on, 6, 2 );
                        my $hour = substr( $scheduled_authored_on, 8, 2 );
                        my $min = substr( $scheduled_authored_on, 10, 2 );
                        my $sec = substr( $scheduled_authored_on, 12, 2 );
                        $param->{ scheduled_authored_on_date } = sprintf( '%04d-%02d-%02d', , $year, $month, $day );
                        $param->{ scheduled_authored_on_time } = sprintf( '%02d:%02d:%02d', $hour, $min, $sec );
                        $set_scheduled_authored_on++;
                    }
                }
            }
            unless ( $set_scheduled_authored_on ) {
                my @tl = offset_time_list( time, $blog );
                $param->{ scheduled_authored_on_date } = sprintf( '%04d-%02d-%02d', $tl[ 5 ] + 1900, $tl[ 4 ] + 1, $tl[ 3 ] );
                $param->{ scheduled_authored_on_time } = sprintf( '%02d:%02d:%02d', $tl[ 2 ], $tl[ 1 ], $tl[ 0 ] );
            }
        }
    }
}

1;
