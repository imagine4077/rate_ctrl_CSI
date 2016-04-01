#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include <pcap.h>
#include <stddef.h>
#include <iostream>

#define BUFFER_SIZE 1024

typedef unsigned int u_int32;
typedef unsigned short u_int16;
typedef unsigned char u_int8;

//radiotap header 14bytes
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

// ieee 80211 data
struct ieee80211dataFlag{
	u_int8 type; // Type/Subtype
	u_int16 fc; // Frame Control
	u_int16 dr; // Duration
	char dest_mac[6]; // Destination address
	char src_mac[6]; // Dource address
	char bss[6]; // BSS Id
	u_int16 fn; //Fragment number
	// Sequence number
	u_int32 seq; // the seq num we added in packets
};

void get_radiotapHeader(struct radiotap_hdr* rtap_header, u_char* pkt_data){
	unsigned long i=0;
	memcpy(&rtap_header->hdr_version,pkt_data,sizeof(rtap_header->hdr_version));
	i=i+sizeof(rtap_header->hdr_version);
	memcpy(&rtap_header->hdr_pad,pkt_data+i,sizeof(rtap_header->hdr_pad));
	i=i+sizeof(rtap_header->hdr_pad);
	memcpy(&rtap_header->hdr_len,pkt_data+i,sizeof(rtap_header->hdr_len));
	i=i+sizeof(rtap_header->hdr_len);
	memcpy(&rtap_header->present_flags,pkt_data+i,sizeof(rtap_header->present_flags));
	i=i+sizeof(rtap_header->present_flags);
	memcpy(&rtap_header->flags,pkt_data+i,sizeof(rtap_header->flags));
	i=i+sizeof(rtap_header->flags);
	memcpy(&rtap_header->data_rate,pkt_data+i,sizeof(rtap_header->data_rate));
	i=i+sizeof(rtap_header->data_rate);
	memcpy(&rtap_header->channel_freq,pkt_data+i,sizeof(rtap_header->channel_freq));
	i=i+sizeof(rtap_header->channel_freq);
	memcpy(&rtap_header->channel_type,pkt_data+i,sizeof(rtap_header->channel_type));
	return;
}

void get_80211dataFlag(struct ieee80211dataFlag* df_header, u_char* pkt_data){
	unsigned long i=14; // skip radiotap_hdr
	memcpy(&df_header->type, pkt_data+i,sizeof(df_header->type));
	// i=i+sizeof(df_header->type);
	memcpy(&df_header->fc, pkt_data+i,sizeof(df_header->fc));
	i=i+sizeof(df_header->fc);
	memcpy(&df_header->dr, pkt_data+i,sizeof(df_header->dr));
	i=i+sizeof(df_header->dr);
	memcpy(&df_header->dest_mac, pkt_data+i,sizeof(df_header->dest_mac));
	i=i+sizeof(df_header->dest_mac);
	memcpy(&df_header->src_mac, pkt_data+i,sizeof(df_header->src_mac));
	i=i+sizeof(df_header->src_mac);
	memcpy(&df_header->bss, pkt_data+i,sizeof(df_header->bss));
	i=i+sizeof(df_header->bss);
	memcpy(&df_header->fn, pkt_data+i,sizeof(df_header->fn));
	i=i+sizeof(df_header->fn);
	// get DIY seq num
	memcpy(&df_header->seq, pkt_data+i, sizeof(df_header->seq));

	return;
}

int parse_pcap_file( char* fname, char* fname_out){
	using std::cout;
	using std::hex;
	using std::dec;
	using std::endl;

	FILE *output;
	struct pcap_pkthdr* pcap_header;
	u_char *pkt_data;
	pcap_t *pcap_handle;
	char error_content[PCAP_ERRBUF_SIZE];
	struct radiotap_hdr *rtap_header=(struct radiotap_hdr*)malloc(sizeof(struct radiotap_hdr));
	struct ieee80211dataFlag *df_header=(struct ieee80211dataFlag*)malloc(sizeof(struct ieee80211dataFlag));
	int reval,i=1;
	char my_time[BUFFER_SIZE];
	
	// open output file
	if((output = fopen(fname_out,"w+")) == NULL){
		printf("error: can not open output file\n");
		return 1;
	}
	// start parsing
	pcap_handle=pcap_open_offline(fname,error_content);
	if(!pcap_handle)
	{
		fprintf(stderr, "Error in opening savefile, %s, for reading: %s\n",fname,error_content );
		exit(1);
	}
	do{
		reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
		get_radiotapHeader(rtap_header, pkt_data);
		strftime(my_time, sizeof(my_time), "%Y-%m-%d %T", localtime(&(pcap_header->ts.tv_sec)));
		get_80211dataFlag(df_header, pkt_data);
		printf("%d: %s\n", i, my_time); //print time
		printf("data_rate:%d  caplen:%u\n",rtap_header->data_rate,pcap_header->caplen);
		printf("seq: %u\n",df_header->seq);
//		cout << "dest_mac: "<< hex << df_header->dest_mac << endl;
		i++;
	}while(pkt_data!=NULL && reval > 0);
	// parsing finished
	fclose(output);
	return 0;
}

int main(int argc, char* argv[]){
	char* pcap_fname = argv[1];
	char* output_fname = (char*)malloc(sizeof(pcap_fname)+10);
	strcpy(output_fname, pcap_fname);
	strcat(output_fname,"._out");
	parse_pcap_file( pcap_fname, output_fname);
}
