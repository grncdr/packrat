#!/bin/bash

#
# WARNING: FTP is an insecure protocol by nature.  It is recommended that you
#          encrypt your backups if you choose to use FTP.

ftp_get_client() {
	for x in lftp ncftp ftp; do
		if [ "`which $x`" ]; then
			client=$x
			break;
		fi
	done
	[ "$client" ] || die "ERROR: No FTP client found.  Install lftp or ncftp."
	echo $client
}

ftp_put() {
	client=`ftp_get_client`
	case $client in
		lftp)  cmd="lftp -e 'put -c -O $FTP_DIR $1' -p $FTP_PORT -u $FTP_USER,$FTP_PASS $FTP_HOST" ;;
		ncftp) cmd="ncftpput -u $FTP_USER -p $FTP_PASS -P $FTP_PORT $FTP_HOST $FTP_DIR $1";;
	esac
	verbose "[FTP] cmd: $cmd"
	$cmd
}

ftp_purge() {
	client=`ftp_get_client`
	case $client in
		lftp)  cmd="lftp -e 'rm $FTP_DIR/$1' -p $FTP_PORT -u $FTP_USER,$FTP_PASS $FTP_HOST" ;;
		ncftp) cmd="echo 'rm $FTP_DIR/$1' | ncftp -u $FTP_USER -p $FTP_PASS -P $FTP_PORT $FTP_HOST";;
	esac
	verbose "[FTP] cmd: $cmd"
	$cmd
}

mod_ftp() {
	for f in $NEW_BACKUPS; do
		ftp_put $f
		[ $? -eq 0 ] || die "ERROR: command did not complete successfully"
	done
}
