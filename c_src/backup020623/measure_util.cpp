#include "measure_util.h"
#include <iostream>
#include <algorithm>
#include <pcap.h>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <deque>
#include <cstddef>
#include <vector>

inline void get_radiotapHeader(struct radiotap_hdr* rtap_header, u_char* pkt_data){
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

inline void get_80211dataFlag(struct ieee80211dataFlag* df_header, u_char* pkt_data){
	unsigned long i=14; // skip radiotap_hdr
	memcpy(&df_header->type, pkt_data+i,sizeof(df_header->type));
	// i=i+sizeof(df_header->type);
	memcpy(&df_header->fc, pkt_data+i,sizeof(df_header->fc));
	i=i+sizeof(df_header->fc);
	memcpy(&df_header->dr, pkt_data+i,sizeof(df_header->dr));
	i=i+sizeof(df_header->dr);
	memcpy(&df_header->dest_mac, pkt_data+i,sizeof(df_header->dest_mac));
	i=i+6; //i=i+sizeof(df_header->dest_mac);
	memcpy(&df_header->src_mac, pkt_data+i,sizeof(df_header->src_mac));
	i=i+6; //i=i+sizeof(df_header->src_mac);
	memcpy(&df_header->bss, pkt_data+i,sizeof(df_header->bss));
	i=i+6; //i=i+sizeof(df_header->bss);
	memcpy(&df_header->fn, pkt_data+i,sizeof(df_header->fn));
	i=i+sizeof(df_header->fn);
	// get DIY seq num
	memcpy(&df_header->seq, pkt_data+i,sizeof(df_header->seq));
	return;
}

int parse_pcap_file( const char* fname, std::vector<struct loss_and_thrpt>& res_vector, unsigned int start_seq){
	struct pcap_pkthdr* pcap_header; // the header of a packet which is added by tcpdump
	u_char *pkt_data; // the packet entity which is consisted of radiotap_hdr, ieee80211dataFlag header and data frame
	pcap_t *pcap_handle;
	char error_content[PCAP_ERRBUF_SIZE];
	struct radiotap_hdr *rtap_header=(struct radiotap_hdr*)malloc(sizeof(struct radiotap_hdr)); // the buffer to restore a radiotap_hdr
	struct ieee80211dataFlag *df_header=(struct ieee80211dataFlag*)malloc(sizeof(struct ieee80211dataFlag));
	int reval,pkt_loss=0;
	char my_time[BUFFER_SIZE];
	
	double first_ts=0.0,ts,real_first;
//	u_int8 dest_mac[6];
//	u_int8 src_mac[6];
	const u_int32 buffer_len=1000;
	u_int32 cyc_queue_buffer[buffer_len],byte_sum =0,i=0,first_seq=0;
	bool queue_empty=true;
	
	//open data dump file
	char* out = (char*)malloc(strlen(fname)+20);
	strcpy(out,fname);
	strcat(out,".thpt");
	printf("%s\n",out);
	FILE *out_fp = fopen(out, "w");

	// open the ts file
	char* ts_file = (char*)malloc(strlen(fname)+20);
	strcpy(ts_file,fname);
	strcat(ts_file,".ts");
	FILE *ts_fp = fopen(ts_file,"w");
	
	// start parsing
	pcap_handle=pcap_open_offline(fname,error_content);
	if(!pcap_handle)
	{
		fprintf(stderr, "Error in opening savefile, %s, for reading: %s\n",fname,error_content );
		exit(1);
	}
	// start parsing every packet
	reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
	while(pkt_data!=NULL && reval > 0){
		get_radiotapHeader(rtap_header, pkt_data);
		get_80211dataFlag(df_header, pkt_data);
		ts=pcap_header->ts.tv_sec+ pcap_header->ts.tv_usec/1000000.0;
		u_int32 tmp_seq = df_header->seq; // seq of this packet
		strftime(my_time, sizeof(my_time), "%Y-%m-%d %T", localtime(&(pcap_header->ts.tv_sec)));
		printf("%d: %s,\t%f\n", i, my_time,ts); //print time // de
		if(i==0) real_first=ts;
		if(ts-real_first<=1)
			fprintf(ts_fp,"%ld\n",pcap_header->ts.tv_usec);

		/** judge if the dest/src mac addr is right **/
		if(!(!memcmp(df_header->dest_mac,"\x00\x16\xea\x12\x34\x56",6)
		||!memcmp(df_header->bss,"\x00\x16\xea\x12\x34\x56",6)
		||!memcmp(df_header->src_mac,"\x00\x16\xea\x12\x34\x56",6))){
			reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
			continue;
		}
/*		if(0==i&&( (start_seq>0&&tmp_seq==start_seq)||start_seq==0 )){
			memcpy(dest_mac,df_header->dest_mac,6);
			memcpy(src_mac,df_header->src_mac,6);
		}
		else if(0!=memcmp(dest_mac,df_header->dest_mac,6)
				&&0!=memcmp(src_mac,df_header->src_mac,6)){
			printf("MAC uneual in %u\n",i);
			reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
			continue;
		}
*/		
		
		printf("data_rate:%d  caplen:%u\n",rtap_header->data_rate,pcap_header->caplen); // de
		printf("seq: %u\n",df_header->seq); // de
		printf("duration: %u\n",df_header->dr); // de
		
		/** if queue is empty **/
		if(queue_empty){
			i=0;
			cyc_queue_buffer[0]= tmp_seq;
			first_ts = ts;
			first_seq = tmp_seq;
			byte_sum =pcap_header->len;
			queue_empty=false;
		}
		/*** if the queue is not empty*/
		else{
			/** if the queue has no this ele 
			*	and the interval with the first packet in queue
			*   is less than 1 second
			* **/
			if(ts-first_ts<=1  && !buffer_hasEle(cyc_queue_buffer, buffer_len, tmp_seq)){
				cyc_queue_buffer[i%buffer_len] = tmp_seq;
				byte_sum = byte_sum + pcap_header->len;
				if(i>0 && (cyc_queue_buffer[(i-1)%buffer_len]+1 != cyc_queue_buffer[i%buffer_len])){ 
					printf("=============\nLOSS:%d\t,%d-%d,i mod buffer_len:%d,buffer_len:%d\n=============\n",
							cyc_queue_buffer[i%buffer_len]-cyc_queue_buffer[(i-1)%buffer_len]-1,
							cyc_queue_buffer[i%buffer_len],cyc_queue_buffer[(i-1)%buffer_len],i%buffer_len,buffer_len);
					pkt_loss+=cyc_queue_buffer[i%buffer_len]-cyc_queue_buffer[(i-1)%buffer_len]-1;
				}
			}
			/** if the interval more than 1s **/
			else if( ts-first_ts>1 ){
				struct loss_and_thrpt tmp = {pkt_loss/(1.0+tmp_seq-first_seq),byte_sum*8/(float)1048576.0};
				res_vector.push_back(tmp);
				printf("pkt_num: %f\tthroughput:%fMbps\n",tmp.pkt_num,tmp.thrpt);
				printf("i:%d,\tall:%d,\tloss:%d\n",i,tmp_seq-first_seq+1,pkt_loss);
				fprintf(out_fp,"%f,%fMbps\n",tmp.pkt_num,tmp.thrpt);
				cyc_queue_buffer[0]= tmp_seq;
				first_ts = ts;
				first_seq= tmp_seq;
				byte_sum = pcap_header->len;
				i = 0;
				pkt_loss=0;
			}
			else
				if(buffer_hasEle(cyc_queue_buffer, buffer_len, tmp_seq))
					std::cout << "retransmit: "<< tmp_seq;
		}
		i++;
		reval = pcap_next_ex(pcap_handle, &pcap_header, (const u_char **)&pkt_data);
	}
	// parsing finished
	/** the last packet may not fullfill 1second interval **/
	struct loss_and_thrpt tmp = {(i+1.0)/(1.0+cyc_queue_buffer[i%buffer_len]-first_seq),byte_sum*8/(ts-first_ts)/(float)1048576.0};
	res_vector.push_back(tmp);
	printf("pkt_num fi: %f\tthroughput:%fMbps\n",tmp.pkt_num,tmp.thrpt);
	fprintf(out_fp,"%f,%fMbps\n",tmp.pkt_num,tmp.thrpt);
	
	fclose( out_fp);
	return 0;
}

inline bool buffer_hasEle(const u_int32 arr[],const u_int32 len, u_int32 x){
	if(len==0)
		return false;
	for(u_int32 i=0;i<len;i++)
		if(x==arr[i]) return true;
	return false;
}
