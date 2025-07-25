package <%= ${class} %>::GuiPlugin::SongForm;
use Mojo::Base 'CallBackery::GuiPlugin::AbstractForm', -async_await, -signatures;
use CallBackery::Translate qw(trm);
use CallBackery::Exception qw(mkerror);
use Mojo::JSON qw(true false);
use Mojo::Util qw(dumper);

use POSIX qw(strftime);

=head1 NAME

LiveUi::GuiPlugin::SongForm - Song Edit Form

=head1 SYNOPSIS

 use LiveUi::GuiPlugin::SongForm;

=head1 DESCRIPTION

The Song Edit Form

=cut

=head1 METHODS

All the methods of L<CallBackery::GuiPlugin::AbstractForm> plus:

=cut

=head2 formCfg

Returns a Configuration Structure for the Song Entry Form.

=cut


my $voices = [
    S => 'Soprano',
    A => 'Alto',
    T => 'Tenor',
    B => 'Bass',
];

my $decades = [
    { title => "Pick!", key => undef }, # The entry with key `0` appears first
    { title => 'Sixties', key => '60s' },
    { title => 'Eighties', key => '80s' },
    { title => 'Nineties', key => '90s' },
    { title => 'Post Vinyl', key => '20+' },
];

my %VOICE;
my @VOICES;

while (@$voices){
    my $key = shift @$voices;
    my $name = shift @$voices;
    $VOICE{$key} = $name;
    push @VOICES, $key;
}

has formCfg => sub ($self){
    my $db = $self->user->db;
    $self->log->debug("formCFG formPhase: ".$self->formPhase);
    $self->log->debug("formCFG formData: ".dumper($self->formData));
    return [
        $self->config->{type} eq 'edit' ? {
            key => 'song_id',
            label => trm('SongId'),
            widget => 'hiddenText',
            set => {
                readOnly => $self->true,
            },
        } : (),

        {
            key => 'song_title',
            label => trm('Title'),
            widget => 'text',
            set => {
                required => $self->true,
            },
        },
        {
            widget => 'header',
            label => trm('Song Details'),
            note => trm('Use the following fields to write down some extra information about the song.')
        },
        (map {
            {
                key => 'song_voice_'.$_,
                label => $VOICE{$_}.' Voice',
                widget => 'checkBox',
                set => {
                    label => trm('Song has a '.$VOICE{$_}.' Part'),
                }
            }
        } @VOICES),
        {
            key              => 'song_decade',
            label            => trm('Song Decade'),
            widget           => 'selectBox',
            triggerFormReset => true,
            set              => {
                required => false
            },
            cfg              => {
                structure => $decades
            }
        },
       {
            key               => 'song_decade_addional',
            label             => trm('Addional Decade info'),
            widget            => 'text',
            reloadOnFormReset => true,
            set               => $self->formData->{song_decade} ?  {
                readOnly    => false,
                placeholder => 'Type something extra',
            } : {
                readOnly    => true,
                placeholder => 'This field becomes available as soon you select a decade',
            },
        },
        {
            key    => 'song_composer',
            label  => trm('Composer'),
            widget => 'text',
            triggerFormReset => true,
            set => {
                liveUpdate => true, # update on every keystroke
                # liveUpdateOnRxMatch => 'lvi', # update only if part of 'elvis' is typed
            },
        },
        {
            key => 'song_page',
            label => trm('Song Page'),
            widget => 'text',
            validator => sub {
                my $value = shift;
                if ($value ne int($value)){
                    return "Expected a page Number";
                }
                return "";
            },
            set => {
                visibility => $self->formData->{song_composer} =~ /elvis/ ? 'visible' : 'excluded',
            }
            
        },
        {
            key => 'song_note',
            label => trm('Note'),
            widget => 'textArea',
            note => trm('Use this area to write down additional notes on the particular song.'),
            set => {
                placeholder => 'some extra information about this song',
            }
        },
    ];
};

has actionCfg => sub ($self) {
    my $type = $self->config->{type} // 'new';

    my $handler = sub {
        my $self = shift;
        my $args = shift;

        $args->{song_voices} = join "", map { $args->{'song_voice_'.$_} ? ($_) : () } @VOICES;

        my @fields = qw(title voices decade decade_addional composer page note);

        my $db = $self->user->db;

        my $id = $db->updateOrInsertData('song',{
            map { $_ => $args->{'song_'.$_} } @fields
        },$args->{song_id} ? { id => int($args->{song_id}) } : ());
        return {
            action => 'dataSaved'
        };
    };

    return [
        {
            label => $type eq 'edit'
               ? trm('Save Changes')
               : trm('Add Tree Node'),
            action => 'submit',
            key => 'save',
            actionHandler => $handler
        }
    ];
};

has grammar => sub ($self){
    $self->mergeGrammar(
        $self->SUPER::grammar,
        {
            _doc => "Tree Node Configuration",
            _vars => [ qw(type) ],
            type => {
                _doc => 'type of form to show: edit, add',
                _re => '(edit|add)'
            },
        },
    );
};

sub getAllFieldValues ($self,$parentForm, $formData,$frontendProps) {
    $self->log->debug("getAllFieldValues parentForm : ".dumper($parentForm));
    $self->log->debug("getAllFieldValues formData : ".dumper($formData));
    $self->log->debug("getAllFieldValues frontendProps : ".dumper($frontendProps));
    # we can also update field values based on the current form data
    if ($formData->{currentFormData}{song_decade} // '' eq '20+' and not $formData->{currentFormData}{song_decade_addional}) {
        return {song_decade_addional => 'We most certainly need more info here!'};
    }
    
    return {} if $self->config->{type} ne 'edit';
    my $id = $parentForm->{selection}{song_id};
    return {} unless $id;

    my $db = $self->user->db;
    my $data = $db->fetchRow('song',{id => $id});
    my $voices = $data->{song_voices};
    for my $v (@VOICES){
        $data->{'song_voice_'.$v} = $voices =~ /$v/ ? $self->true : $self->false;
;
    }
    return $data;
}

has checkAccess => sub {
    my $self = shift;
    return $self->user->may('write');
};

1;
__END__

=head1 AUTHOR

S<<%== ${fullName} %> E<lt><%= ${email} %>E<gt>>

=head1 HISTORY

 <%= "${date} ${userName}" %> 0.0 first version

=cut
