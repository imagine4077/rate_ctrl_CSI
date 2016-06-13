#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <linux/types.h>
#include <ctime>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <cstdlib>
#include <signal.h>
#include <cmath>

#define VALID_THRESHOLD 200
#define BUFFER_SIZE 2046

struct loss_and_thrpt{
	float pkt_num;
	float thrpt;
};

inline bool buffer_hasEle(const uint32_t arr[],const uint32_t len,
	   	uint32_t x){
	if(len==0)
		return false;
	for(uint32_t i=0;i<len;i++)
		if(x==arr[i]) return true;
	return false;
}


FILE *fp_raw = fopen("raw.txt","w"), *fp_thpt=fopen("thpt.txt","w");

void handler(int sig){
	fclose(fp_raw);
	fclose(fp_thpt);
	printf("SIGINT catched %d\n",sig);
	exit(0);
}

int main(int argc, char* argv[]){
	using  namespace std;
	int server_sock = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP),tmp_len;
	const uint32_t buffer_len=1000;
	uint32_t tmp_seq,cyc_queue_buffer[buffer_len],byte_sum =0,i=0,first_seq=0,pkt_loss=0;
	bool queue_empty=true;
	struct sockaddr_in serverAddr,clientAddr;
	time_t now,first_ts;

	/** close files when catch CTRL+C **/
	signal(SIGINT,handler);

	socklen_t sockaddr_len = sizeof(struct sockaddr);
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(1234);
	serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	char buffer[BUFFER_SIZE];
	bind(server_sock,(struct sockaddr*)&serverAddr,sockaddr_len);
	while(true){
		bzero(buffer,BUFFER_SIZE);
		recvfrom(server_sock,buffer,BUFFER_SIZE,0,
				(struct sockaddr*)&clientAddr,&sockaddr_len);
		time(&now);
		memcpy(&tmp_seq,buffer,4);
		tmp_len = strlen(buffer)+8;
		fprintf(fp_raw,"%ld,%u,%u\n",now,tmp_seq,tmp_len);
		
		/** if queue is empty **/
		if(queue_empty){
			i=0;
			cyc_queue_buffer[0]= tmp_seq;
			first_ts = now;
			first_seq = tmp_seq;
			byte_sum = tmp_len;
			queue_empty=false;
			printf("first_seq:%u\n",tmp_seq);
		}
		/*** if the queue is not empty*/
		else{
			/** if the queue has no this ele 
			*	and the interval with the first packet in queue
			*   is less than 1 second
			* **/
			if(difftime(now,first_ts)<=1  && !buffer_hasEle(cyc_queue_buffer, buffer_len, tmp_seq)){
				if(i>0 && abs(tmp_seq- cyc_queue_buffer[(i-1)%buffer_len])>VALID_THRESHOLD){
					printf("wrong packet received\n");
					printf("++++++++++++++++++++\nLOSS:%d\t,%d-%d=abs %f,i mod buffer_len:%d,buffer_len:%d\n++++++++++\n",
							cyc_queue_buffer[i%buffer_len]-cyc_queue_buffer[(i-1)%buffer_len]-1,
							cyc_queue_buffer[i%buffer_len],cyc_queue_buffer[(i-1)%buffer_len],
							abs(tmp_seq- cyc_queue_buffer[(i-1)%buffer_len]),i%buffer_len,buffer_len);
					continue;
				} 
				cyc_queue_buffer[i%buffer_len] = tmp_seq;
				byte_sum = byte_sum + tmp_len;
				if(i>0 && (cyc_queue_buffer[(i-1)%buffer_len]+1 != cyc_queue_buffer[i%buffer_len])){ 
					printf("=============\nLOSS:%d\t,%d-%d,i mod buffer_len:%d,buffer_len:%d\n=============\n",
							cyc_queue_buffer[i%buffer_len]-cyc_queue_buffer[(i-1)%buffer_len]-1,
							cyc_queue_buffer[i%buffer_len],cyc_queue_buffer[(i-1)%buffer_len],i%buffer_len,buffer_len);
					pkt_loss+=cyc_queue_buffer[i%buffer_len]-cyc_queue_buffer[(i-1)%buffer_len]-1;
				}
			}
			/** if the interval more than 1s **/
			else if( difftime(now,first_ts)>1 ){
				struct loss_and_thrpt tmp = {pkt_loss/(1.0+tmp_seq-first_seq),byte_sum*8/(float)1048576.0};
				printf("pkt_lose: %f\tthroughput:%fMbps\n",tmp.pkt_num,tmp.thrpt);
				fprintf(fp_thpt,"pkt_lose: %f\tthroughput:%fMbps\n",tmp.pkt_num,tmp.thrpt);
				printf("first_seq:%u\n",tmp_seq);
				cyc_queue_buffer[0]= tmp_seq;
				first_ts = now;
				first_seq= tmp_seq;
				byte_sum = tmp_len;
				i = 0;
				pkt_loss=0;
			}
			else
				if(buffer_hasEle(cyc_queue_buffer, buffer_len, tmp_seq))
					cout << "retransmit: "<< tmp_seq<<endl;
		}
		i++;
	}
	close(server_sock);
	return 0;
}
