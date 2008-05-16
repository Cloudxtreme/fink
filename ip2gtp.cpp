/*
 * tcpserver.c
 *
 * Example BSD TCP socket server. 
 * Paired with tcpclient.c.
 *
 * OS: SunOS
 * compiler: cc
 *	% cc -o tcpserver -g tcpserver.c
 *
 * To run:
 *	% tcpserver&
 *	% tcpclient localhost 
 *
 * The server listen on a #define hardwired port TCPPORT (see below).
 * It accepts some number of requests from the client and turns around
 * and writes those buffers back to the client.
 *
 * This is a simple test server.  A more 'normal' server would start
 * at boot and block in an accept call (or be coded for the UNIX inetd
 * which is in turn different).  After the accept call, the server would
 * fork a child to handle the connection.   This server simply handles
 * one connection and exits.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <unistd.h>

using namespace std;


#define TRUE 1
#define FALSE 0

#define TCPPORT 10000		/* server port value */
#define BUFSIZE 1024		/* size of i/o buffer */
#define NOREADS 10		/* number of buffers transferred */

/* 
 * create socket
 * bind to address
 */
int initSocket()
{
	struct sockaddr_in server;
	int sock;
	int optval = 1;
	int retVal;

	/* create INTERNET,TCP socket
	*/
	sock = socket(AF_INET, SOCK_STREAM, 0); 

	if ( sock < 0 ) {
		perror("socket");
		exit(1);
	}

	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;   

	server.sin_port = htons(TCPPORT);      /* specific port */

	/* bind protocol to socket
	*/
	if (bind(sock, (struct sockaddr *)  &server, sizeof(server))) {
		perror("bind");
		exit(1);
	}

	//retVal = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char *)&optval, sizeof(optval));
	setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,(int *)&optval, sizeof(optval)) ;
	return(sock);
}

void doWrite(int sock, char *buf)
{
	int len = strlen(buf);
	char slen[8];
	int rc;
	sprintf(slen, "%04d", len);
	rc = write(sock, slen, 4); 
	if (rc < 0) {
		perror("write");
		exit(1);
	}
	write(sock, buf, len);
	if (rc < 0) {
		perror("write");
		exit(1);
	}
}
		

/* read from socket. Read call issued to kernel
 * may return with incomplete data. This routine
 * must check that and force a complete read.
 */
void doRead(int sock, char *buf)
{
	register int i;
	int rc;
	char *bpt;
	int count;
	int amountNeeded;
	int amtread;
	
	bpt = buf;

	rc =0;
	while (rc < 4) {
		rc += read(sock, bpt, 4-rc);
		bpt += rc;
	}
	amountNeeded = atoi(buf);
	count = amountNeeded;
	bpt = buf;

	amtread = 0;

again:
	if ( (rc = read(sock,bpt,count)) < 0 ) {
		perror("doRead: reading socket stream");
		exit(1);
	}
	amtread += rc;

	if ( amtread < amountNeeded ) {
		count = count - rc;	
		bpt = bpt + rc;
		goto again;
	}
	buf[amountNeeded] = '\0';
}


int main(int argc,char **argv)
{
	int sock;
	int size;
	char buf[BUFSIZE];
	int msgsock;
	struct sockaddr_in gotcha;
	int rc;
	int i;
	char *cp;
	char port[16];
	pid_t pid;
	

	

	sock = initSocket();

	/* tcp starts listening for connections
	*/
	rc = listen(sock,5);
	if ( rc < 0) {
		perror("listen");
		exit(1);
	}
	/* accept one connection, will block here.
	*/
	size = sizeof (struct sockaddr_in);
	pid = fork();
	if (pid == 0) {
		//sprintf(buf, "/home/dan/src/my/gobot/gobot.sh 127.0.0.1 %d 2>&1 /dev/null\n",  TCPPORT);
		sprintf(buf, "/usr/bin/sbcl --noinform --load /home/dan/src/my/gobot/fink.fasl --eval '(progn (gtp-handler:gtp-net-client \"127.0.0.1\" %d) (quit))' \n", TCPPORT);

		//printf("%s\n", buf);
		system(buf);
		return 0;
	}
	/* gotcha and size are returned when the connection comes in.
  	 * When the client calls connect, and a connection occurs, accept
 	 * returns.  gotcha holds the client ip address and client port value.
	 * NOTE: the size parameter is a *pointer*, not an integer.  The
	 * kernel returns the size of the socket structure in gotcha.
	 * This is called: "call by value-result". You have to pass in
	 * the size of the structure and the kernel returns the true result.
	 * For tcp/ip sockets the size never changes.  For unix sockets
	 * it may change.
	 */
	msgsock = accept(sock, (struct sockaddr *) &gotcha, (socklen_t*)&size);	
	if (msgsock < 0 ) {
		perror("accept");
		exit(1);
	}

	/* read and echo so many packets
	*/
	/*for ( i = 0; i < NOREADS; i++) {
		doRead(msgsock, buf, BUFSIZE);
		rc = write(msgsock, buf, BUFSIZE); 
		if ( rc < 0 ) {
			perror("write");
			exit(1);
		}
	}*/
	do {
		cin.getline(buf, BUFSIZE);
		//printf("%s", buf);
		doWrite(msgsock, buf);				
		buf[0] = '\0';
		doRead(msgsock, buf);
		//printf("%s", buf);
		cout << buf;
		buf[0] = '\0';
	} while (1);

	/* close sockets
	*/
	close(msgsock);
	close(sock);

	return(0);
}


