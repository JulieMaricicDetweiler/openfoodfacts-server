#!/usr/bin/perl -w

# This file is part of Product Opener.
#
# Product Opener
# Copyright (C) 2011-2020 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Fossés, France
#
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use ProductOpener::PerlStandards;

use CGI::Carp qw(fatalsToBrowser);

use ProductOpener::Config qw/:all/;
use ProductOpener::Store qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Users qw/:all/;
use ProductOpener::Lang qw/:all/;

use Apache2::Const -compile => qw(OK);
use CGI qw/:cgi :form escapeHTML/;
use URI::Escape::XS;
use Encode;
use Log::Any qw($log);

$log->info('start') if $log->is_info();

my $request_ref = ProductOpener::Display::init_request();

my $status = 403;

if (defined $User_id) {
	$status = 200;
}

print header(-status => $status);

# We need to send the header Access-Control-Allow-Credentials=true so that websites
# such has hunger.openfoodfacts.org that send a query to world.openfoodfacts.org/cgi/auth.pl
# can read the resulting response.

# The Access-Control-Allow-Origin header must be set to the value of the Origin header
my $r = Apache2::RequestUtil->request();
my $origin = $r->headers_in->{Origin} || '';

# Only allow requests from one of our subdomains to see if a user is logged in or not

if ($origin =~ /^https:\/\/[a-z0-9-.]+\.${server_domain}(:\d+)?$/) {
	$r->err_headers_out->set("Access-Control-Allow-Credentials", "true");
	$r->err_headers_out->set("Access-Control-Allow-Origin", $origin);
}

$r->rflush;
$r->status($status);
