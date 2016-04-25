#ifndef INJECTION_UTIL
#define INJECTION_UTIL

#include <cctype>
#include <cstddef>
#include <pcap.h>
#include <deque>
#include <vector>


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

// ieee 80211 data 24bytes without seq; 28 bytes within seq
struct ieee80211dataFlag{
	u_int8 type; // Type/Subtype
	u_int16 fc; // Frame Control
	u_int16 dr; // Duration
	u_int8 dest_mac[6]; // Destination address
	u_int8 src_mac[6]; // Dource address
	u_int8 bss[6]; // BSS Id
	u_int16 fn; //Fragment number
	// Sequence number
	u_int32 seq; // the seq num we added in packets
};

struct loss_and_thrpt{
	u_int32 pkt_num;
	float thrpt;
};

int parse_pcap_file( const char* fname, std::vector<struct loss_and_thrpt>& res_vector,unsigned int start_seq=0);
inline void get_radiotapHeader(struct radiotap_hdr* rtap_header, u_char* pkt_data);
inline void get_80211dataFlag(struct ieee80211dataFlag* df_header, u_char* pkt_data);
inline bool buffer_hasEle(const u_int32 arr[],const u_int32 len, u_int32 x);

#endif
