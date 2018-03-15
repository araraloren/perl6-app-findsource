

use Getopt::Advance::Parser;

sub config-loader-parser(@args, $optset, |c) is export {
    my (@loadop, @config, @noa);
	my %configs = shift @args;

    loop (my $i = 0;$i < +@args; $i++) {
        if @args[$i] eq '-l' {
            @loadop.push($i);
            @config.push(@args[++$i]);
        } else {
            @noa.push(@args[$i]);
        }
    }

	my %category := SetHash.new;

    for @config.sort.unique -> $name {
        my @options := %configs{$name}<option>;

        for @options -> $option {
            my $short = $option<short>;

            %category{$short} = True;
            if $optset.has($short) {
                my $o = $optset.get($short);
                my @old := $o.default-value // [];

                @old.append($option<value>);
                @old = @old.sort.unique;
                $o.set-default-value(@old);
            } else {
                $optset.push(
                    "{$short}| = a",
                    $option<annotation>,
                    value => @($option<value>)
                );
            }
        }
    }

    return Getopt::Advance::ReturnValue.new(
        optionset => $optset,
        noa => @noa,
        return-value => %category,
    );
}
