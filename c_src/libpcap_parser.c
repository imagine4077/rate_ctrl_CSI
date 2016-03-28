#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include <pcap.h>
#include <stddef.h>

#define BUFFER_SIZE 1024

char* pcap_fname = "../data/160312-103940.pcap"; //在此指定pcap文件名
char* output_fname = "data.out"; //在此指出输出文件名

//typedef long bpf_int32;
//typedef unsigned long bpf_u_int32;
typedef unsigned short  u_short;
typedef unsigned long u_int32;
typedef unsigned short u_int16;
typedef unsigned char u_int8;

//radiotap header 14字节
struct radiotap_hdr{
	u_int8 hdr_version;
	u_int8 hdr_pad;
	u_int16 hdr_len;
	u_int32 present_flags;
	u_int8 flags;
	u_int8 data_rate;
	u_int16 channel_freq;
	u_int16 channel_type;
};

int parse_pcap_file( char* fname, char* fname_out){
	FILE *fp, *output;
	struct pcap_pkthdr* pcap_header;
	u_char *pkt_data;
	pcap_t *pcap_handle;
	char error_content[PCAP_ERRBUF_SIZE];
	struct radiotap_hdr *rtap_header;
	int reval,i=1;
	char my_time[BUFFER_SIZE];
	
	if((fp = fopen(fname,"r")) == NULL){
		printf("error: can not open pcap file\n");
		return 1;
	}
	if((output = fopen(fname_out,"w+")) == NULL){
		printf("error: can not open output file\n");
		return 1;
	}
	pcap_handle=pcap_open_offline(fname,error_content);
	if(!pcap_handle)
	{
		fprintf(stderr, "Error in opening savefile, %s, for reading: %s\n",fname,error_content );
		exit(1);
	}
	do{
		reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
		memcpy(rtap_header,pkt_data,sizeof(rtap_header));
		strftime(my_time, sizeof(my_time), "%Y-%m-%d %T", localtime(&(pcap_header->ts.tv_sec)));
		printf("%d: %s\n", i, my_time); //print time
		printf("data_rate:%u  caplen:%u\n",rtap_header->data_rate,pcap_header->caplen);
		i++;
	}while(pkt_data!=NULL && reval > 0);
	fclose(fp);
	fclose(output);
	return 0;
}

int main(){
	parse_pcap_file( pcap_fname, output_fname);
}
