# DDNS
Dynamic DNS server using Digital Ocean's DNS v2 API with Dancer Front-End

In the lib directory, there are two versions of DDNS.pm.  The default packages uses
DigitalOce Ocean's perl module.  The other version uses a shell script.  

The Digital Ocean module required a newer version of Perl than I was using.  So, I
used the shell script version until I deployed Perlbrew with an updated version on 
my server.  At that point, I changed over to using the Perl module provided by 
Digital Ocean.
