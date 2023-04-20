class IsaGetter < ApplicationService
  attr_reader :id
  def initialize(sciper)
    @id = sciper
  end

  def fetch
    # curl https://isa.epfl.ch/services/teachers/103561 | jq
    # ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561'" | jq
    uri=URI.parse(url)
    req = Net::HTTP::Get.new(uri)
    opts={:use_ssl => true, :read_timeout => 100}
    if Rails.configuration.isa_no_check_ssl
      opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
    end
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPOK then
      JSON.parse(res.body)
    else
      nil
    end
  end

  def expire_in
    72.hours
  end

  def url
   raise 'Attempt to use url method of IsaGetter which is an "abstract class"'
  end
end


# my $ISAURL          = $DEBUG
#                     ? "https://isatest.epfl.ch/services"
#                     : "https://isa.epfl.ch/services";
# $ISAURL = $ENV{ISAURL} if $ENV{ISAURL};
# my $wsISA_progPhd   = $ISAURL."/teachers/PROGCODE/thesis/directors" ;
# my $wsISA_teachers  = $ISAURL."/teachers" ;
# my $wsISA_thesis    = $ISAURL."/teachers/SCIPER/thesis/directors/doctorants" ;


# #____________________
# sub get_wsTeachingActivity {
#   my ($self, $sciper) = @_;
#   return unless $sciper;

#   return get_cacheTeachingActivity ($self, $sciper) if $FORCE_USE_ISACACHE;

# #warn "--> get_wsTeachingActivity : $sciper\n";
#   my ($hasTeachingAct, $sectionLabel, $secondarySections, @pdocsarray, @crtDoctAct, @pastDoctAct, $pdocstxt, $secsecttxt);
#   my $url    = $wsISA_teachers."/$sciper" ;
#   my $result = getISA($self, $url);

#   # - handle ISA ws error : return cache
#   return get_cacheTeachingActivity ($self, $sciper) if $FORCE_USE_ISACACHE;

#   if ($result->{enseignement} &&
#       ( !$result->{enseignement}->{dateEnseignementFin} ||
#         ($result->{enseignement}->{dateEnseignementFin} &&
#          $result->{enseignement}->{dateEnseignementFin} ge $self->{date}->{crt_date}
#         )
#       )
#      )
#   {
#     foreach my $sect (@{$result->{enseignement}->{ensignementSecPrimaire}}) {
#       next if $sect->{dateFinValidite} && $sect->{dateFinValidite} lt $self->{date}->{crt_date};
#       $sectionLabel .= $sect->{programme}->{name}->{$self->{cvlang}}.',';
#       $secsecttxt   .= "$sect->{programme}->{name}->{fr}:$sect->{programme}->{name}->{en},";
#     }
#     $secsecttxt    =~ s/,$//;
#     $secsecttxt   .=  ';';
#     foreach my $sect (@{$result->{enseignement}->{enseignementSecSecondondaire}}) {
#       next if $sect->{dateFinValidite} && $sect->{dateFinValidite} lt $self->{date}->{crt_date};
#       $secondarySections .= $sect->{programme}->{name}->{$self->{cvlang}}.',';
#       $secsecttxt        .= "$sect->{programme}->{name}->{fr}:$sect->{programme}->{name}->{en},";
#     }
#     foreach my $progdoct (@{$result->{enseignement}->{directorThese}}) {
#       next if $progdoct->{dateFinValidite} && $progdoct->{dateFinValidite} lt $self->{date}->{crt_date};
#       push @pdocsarray, { label => $progdoct->{programme}->{officialName}->{$self->{cvlang}}, };
#       $pdocstxt .= qq{$progdoct->{programme}->{officialName}->{fr}:$progdoct->{programme}->{officialName}->{en}:$progdoct->{programme}->{shortCode}->{fr};};
#     }
#     $hasTeachingAct = $sectionLabel || $secondarySections || (scalar @pdocsarray)  ;
#   }
#   $sectionLabel      =~ s/,$//;
#   $secondarySections =~ s/,$//;
#   $secsecttxt        =~ s/,$//;

#   utf8::decode($sectionLabel);
#   utf8::decode($secondarySections);
#   utf8::decode($secsecttxt);
#   utf8::decode($pdocstxt);

#   my $crt_date = $self->{date}->{crt_date};
#   #   $crt_date =~ s/\-//g;

#   # - get PhD data
#   my $url = $wsISA_thesis;
#      $url =~ s/SCIPER/$sciper/;

#   my $struct_json = getISA($self, $url) ;
#   return get_cacheTeachingActivity ($self, $sciper) if $FORCE_USE_ISACACHE;

#   if ($struct_json) {
#     foreach my $these (@{$struct_json}) {
#       my $stud_sciper = $these->{doctorant}->{sciper};
#       next unless $stud_sciper;
#       my $stud_name    = $these->{doctorant}->{lastName}.' '.$these->{doctorant}->{firstName};
#       utf8::decode($stud_name);
#       my $thesisNumber = $these->{thesis}->{number} ? $these->{thesis}->{number} : '';
#       my $date_exmat   = $these->{dateExmatriculation} ? $these->{dateExmatriculation} : '';

#       if ($date_exmat) {
#         my ($dd,$mm,$aa) = split /\./, $date_exmat;
#         my $dateexmat  = $aa.'-'.$mm.'-'.$dd;
#         if ( $dateexmat lt $crt_date ) {
#           push @pastDoctAct, {
#            name       => $stud_name,
#            sciperId   => $stud_sciper,
#            mailId     => getMailID($stud_sciper),
#            thesisNumber => $thesisNumber,
#           };
#         } else {
#           $thesisNumber = '' unless $date_exmat;
#           push @crtDoctAct, {
#            name       => $stud_name,
#            sciperId   => $stud_sciper,
#            mailId     => getMailID($stud_sciper),
#            thesisNumber => $thesisNumber,
#           };
#         }
#       } else {
#           $thesisNumber = '' unless $date_exmat;
#           push @crtDoctAct, {
#            name       => $stud_name,
#            sciperId   => $stud_sciper,
#            mailId     => getMailID($stud_sciper),
#            thesisNumber => $thesisNumber,
#           };
#       }
#       $hasTeachingAct = 1;
#     }
#   }

#   @crtDoctAct  = sort { $a->{name} cmp $b->{name} } @crtDoctAct;
#   @pastDoctAct = sort { $a->{name} cmp $b->{name} } @pastDoctAct;

#   if ($UPDATE_ISACACHE) {
#     # - CACHE WS DATA
# #   warn "  >> cache ISA data : $sciper\n";

#     my $phdstudstxt;
#     foreach my $item (@crtDoctAct) {
#       $phdstudstxt .= "$item->{name},$item->{sciperId},$item->{thesisNumber}_";
#     }
#     $phdstudstxt .= ";";
#     foreach my $item (@pastDoctAct) {
#       $phdstudstxt .= "$item->{name},$item->{sciperId},$item->{thesisNumber}_";
#     }
#     $phdstudstxt =~ s/_$//;
#     $pdocstxt    =~ s/;$//;

#     # create or update
#     my $dbh = $self->{dbh};
#     my $sql = qq{select * from teachingact where sciper=?};
#     my $sth = $dbh->prepare( $sql) or die "** ERR people prepare :$sql: $DBI::errstr\n";
#     $sth->execute (($sciper)) or die "** ERR execute : $DBI::errstr\n";
#     if ($sth->fetchrow()) {
#       my $sql = qq{update teachingact set pdocs=?, tsect=?, phdstuds=?, ts=now() where sciper = ? };
#       my $sth = $dbh->prepare( $sql) or die "** ERR people prepare :$sql: $DBI::errstr\n";
#       $sth->execute (($pdocstxt, $secsecttxt, $phdstudstxt, $sciper))or die "** ERR execute : $DBI::errstr\n"
#     } else {
#       my $sql = qq{insert into teachingact set sciper=?, pdocs=?, tsect=?, phdstuds=? };
#       my $sth = $dbh->prepare( $sql) or die "** ERR people prepare :$sql: $DBI::errstr\n";
#       $sth->execute (($sciper, $pdocstxt, $secsecttxt, $phdstudstxt))or die "** ERR execute : $DBI::errstr\n" ;
#     }
#   }

#   # - DONE
#   return {
#       sectionLabel      => $sectionLabel,
#       secondarySections => $secondarySections,
#       crtDoctAct        => \@crtDoctAct,
#       pastDoctAct       => \@pastDoctAct,
#       progsDoct         => \@pdocsarray,
#   };
# }
#
# sub getISA {
#   my ($self, $url) = @_;
#   return '' unless $url;
#   my $ua = LWP::UserAgent->new;
#      $ua->env_proxy;
#   my $results;
#   eval {
#     local $SIG{ALRM} = sub { die "alarm clock restart" };
#     alarm 3;                   # schedule alarm in 10 seconds
#     eval {
#       my $rest = $ua->get ($url);
#       if ($rest->is_success) {
#         $results = decode_json( $rest->content ) if $rest->content ne 'null';
#         $FORCE_USE_ISACACHE = 0;
#       } else {
#         warn time()." getISA $url ERROR\n";
#         $FORCE_USE_ISACACHE = 1;
#         $UPDATE_ISACACHE    = 0;
#         return '0';
#       }
#     };
#     alarm(0);
#   };
#   alarm(0);
#   die if $@ && $@ !~ /alarm clock restart/; # reraise
#   return $results;

# }
