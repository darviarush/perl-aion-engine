requires 'perl', '5.22.0';

on 'develop' => sub {
    requires 'Data::Printer', '1.000004';
    requires 'Liveman', '1.0';
    requires 'Minilla', 'v3.1.19';
};

on 'test' => sub {
	requires 'Test::More', '0.98';
};

requires 'config', '1.3';
requires 'common::sense', '0';
