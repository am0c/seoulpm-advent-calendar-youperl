package YouPerl;
use Dancer ':syntax';
use Dancer::Plugin::Redis;

our $VERSION = '0.1';

sub items2files {
    my @files = map {
        my $f = (glob "public/img/$_.*")[0];
        $f =~ s|public/img/||;
        $f;
    } @_;
    return \@files;
}

get '/' => sub {
    template 'index';
};

get '/category/:name' => sub {
    my $name = params->{name};

    my @items = redis->lrange("youperl:img:cat.$name:0", 0, -1);
    my $files = items2files @items;
    template 'images', { images => $files };
};

get '/category/:name/**' => sub {
    my $name = params->{name};
    var category => $name;
    pass;
};

prefix '/category/*';
get '/color/:name' => sub {
    my $color    = params->{name};
    my $category = vars->{category};

    my @items = redis->smembers("youperl:img:cat.$category.color:0:$color");
    my $files = items2files @items;
    template 'images', { images => $files };
};


true;
