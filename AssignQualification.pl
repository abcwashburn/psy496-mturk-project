#!/usr/bin/perl
use strict; use warnings;
# Use modules
use LWP;
use Digest::HMAC_SHA1 qw(hmac_sha1);
use MIME::Base64;
use XML::XPath;
use Date::Format;
open(PFILE,"id.txt") || die "cannot open idfile $!" ;
my $i = 0;
while (<PFILE>) {
chomp;
###### MAKE 1ST CHANGE HERE ######
#Insert what you want the qualification to be named in $qual_id, replacing "QUALIFICATION ID GOES HERE"
#Insert the integer value you want the user to recieve in $int_val, replacing 100
#If you wish to notify the user that they have recieved a qualification, change the 0 in $notify to 1. If not, leave as-is. 
my $qual_id = "QUALIFICATION ID GOES HERE";
my $int_val = 100;
my $notify = 0;
###### MAKE 2ND CHANGE HERE ######
#Sign up for Amazon web services here:
# https://aws-portal.amazon.com/gp/aws/developer/registration/index.html
#Look up your personal requester "Access Key ID" with this link and insert below (replacing "ACCESS KEY ID GOES HERE")
# http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
my $AWS_ACCESS_KEY_ID = "ACCESS KEY ID GOES HERE";
#from the same page, look up your secret access key and insert below (replacing "SECRET ACCESS KEY GOES HERE")
my $AWS_SECRET_ACCESS_KEY = "SECRET ACCESS KEY GOES HERE";
###### THAT'S IT, NO MORE CHANGES ######
###### LEAVE BELOW UNCHANGED ######
my $SERVICE_NAME = "AWSMechanicalTurkRequester";
my $SERVICE_VERSION = "2013-11-15";
# Define authentication routines- never change
sub generate_timestamp {
my ($t) = @_;
return time2str('%Y-%m-%dT%H:%M:%SZ', $t, 'GMT');
}
sub generate_signature {
my ($service, $operation, $timestamp, $secret_access_key) = @_;
my $string_to_encode = $service . $operation . $timestamp;
my $hmac = hmac_sha1($string_to_encode, $secret_access_key);
my $signature = encode_base64($hmac);
chop $signature;
return $signature;
}
# Calculate the request authentication parameters
my $operation = "AssignQualification";
my $timestamp = generate_timestamp(time);
my $signature = generate_signature($SERVICE_NAME, $operation, $timestamp, $AWS_SECRET_ACCESS_KEY);
#this doesn't change, as it looks at each line of the id file you open.
my $workerid = $_;
# Construct the request
my $parameters = {
Service => $SERVICE_NAME,
Version => $SERVICE_VERSION,
AWSAccessKeyId => $AWS_ACCESS_KEY_ID,
Timestamp => $timestamp,
Signature => $signature,
Operation => $operation,
QualificationTypeId => $qual_id,
IntegerValue => $int_val,
SendNotification => $notify,
WorkerId => $workerid,
};
# Make the request
my $url = "https://mechanicalturk.amazonaws.com/?Service=AWSMechanicalTurkRequester";
my $ua = LWP::UserAgent->new;
my $response = $ua->post($url, $parameters);
$i++;
sleep 5
}
