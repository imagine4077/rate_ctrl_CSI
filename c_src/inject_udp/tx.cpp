#include <linux/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <cstdio>
#include <cstring>
#include <time.h>
#include <cstdlib>

#include "util.h"

uint8_t *payload_buffer;
#define PAYLOAD_SIZE	2000000

struct udp_pkt{
	char ip[32];
	int sock;
	struct sockaddr_in serverAddr;
	uint32_t payload_len;
	uint8_t* payload;
};

int32_t txpacket(struct udp_pkt pkt);
static void init_socket(struct udp_pkt* pkt,char* ip, uint32_t size);

static inline void payload_memcpy(uint8_t *dest, uint32_t length,
		uint32_t offset, uint32_t count)
{
	uint32_t i;
	for (i = 0; i < length; ++i) {
		dest[i] = payload_buffer[(offset + i) % PAYLOAD_SIZE];
	}
	// add seq to the payload of every packets
	memcpy(dest,&count,sizeof(count));
}

int main(int argc, char* argv[]){
	uint32_t num_packets;
	uint32_t packet_size;
	uint32_t i;
	int32_t ret;
	uint32_t delay_us;
	struct timespec start, now;
	int32_t diff;
	struct udp_pkt* packet;

	/* Parse arguments */
	if (argc > 5|| argc<2) {
		printf("Usage: tx <serverIP> <number> <length> <delay in us>\n");
		return 1;
	}
	if (argc < 5 || (1 != sscanf(argv[4], "%u", &delay_us))) {
		delay_us = 0;
	}
	if (argc < 4 || (1 != sscanf(argv[3], "%u", &packet_size)))
		packet_size = 2200;
	if (argc < 3 || (1 != sscanf(argv[2], "%u", &num_packets)))
		num_packets = 10000;

	packet_size = packet_size - 8;
	/* Generate packet payloads */
	printf("Generating packet payloads \n");
	payload_buffer = (uint8_t*)malloc(PAYLOAD_SIZE);
	if (payload_buffer == NULL) {
		perror("malloc payload buffer");
		exit(1);
	}
	generate_payloads(payload_buffer, PAYLOAD_SIZE);

	/* Allocate packet */
	if (packet_size<=12){ // 8 bytes for udp header, 4 for uint32 seq. 8+4 = 12.
		perror("packet_size invalid");
		exit(1);
	}
	packet = (struct udp_pkt*)malloc(sizeof(struct udp_pkt));
	if (!packet) {
		perror("malloc packet");
		exit(1);
	}
	/* Setup the interface for lorcon */
	printf("Initializing UDP\n");
	init_socket(packet,argv[1],packet_size);
	packet->payload = (uint8_t*)malloc( packet_size+8);

	/* Send packets */
	printf("Sending %u packets of size %u (. every thousand)\n", num_packets, packet_size+8);
	if (delay_us) {
		/* Get start time */
		clock_gettime(CLOCK_MONOTONIC, &start);
	}
	for (i = 0; i < num_packets; ++i) {
		payload_memcpy(packet->payload, packet_size,
				(i*packet_size) % PAYLOAD_SIZE, i);

		if (delay_us) {
			clock_gettime(CLOCK_MONOTONIC, &now);
			diff = (now.tv_sec - start.tv_sec) * 1000000 +
			       (now.tv_nsec - start.tv_nsec + 500) / 1000;
			diff = delay_us*i - diff;
			if (diff > 0 && diff < delay_us)
				usleep(diff);
		}

		ret = txpacket(*packet);
		if (ret < 0) {
			fprintf(stderr, "Unable to transmit packet: \n");
			exit(1);
		}

		if (((i+1) % 1000) == 0) {
			printf(".");
			fflush(stdout);
		}
		if (((i+1) % 50000) == 0) {
			printf("%dk\n", (i+1)/1000);
			fflush(stdout);
		}
	}

	return 0;
}

static void init_socket(struct udp_pkt* pkt,char* ip, uint32_t size)
{
	memset(pkt,0,sizeof(struct udp_pkt));
	pkt->sock = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
	strcpy(pkt->ip,ip);
	pkt->serverAddr.sin_family = AF_INET;
	pkt->serverAddr.sin_port = htons(1234);
	pkt->serverAddr.sin_addr.s_addr = inet_addr(ip);
	pkt->payload_len = size;
}

int32_t txpacket(struct udp_pkt pkt){
	int32_t ret = sendto(pkt.sock,pkt.payload,pkt.payload_len,0,
			(struct sockaddr*)&(pkt.serverAddr),
			sizeof(pkt.serverAddr));
	return ret;
}
