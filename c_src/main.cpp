#include "measure_util.h"
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <cstdio>

inline void print_vector(const std::vector<struct loss_and_thrpt> vec);

int main(int argc, char* argv[]){
	using std::deque;
	using std::cout;
	using std::endl;

	if(argc < 2){
		printf("wrong argument\n");
		exit(1);
	}
	char* pcap_fname = argv[1];
	char* output_fname = (char*)malloc(sizeof(pcap_fname)+10);
	static std::vector<struct loss_and_thrpt> res_vector;
	strcpy(output_fname, pcap_fname);
	strcat(output_fname,"._out");
	printf("outfile: %s\n",output_fname);
	if(!strcmp(argv[2],"1"))
		freopen(output_fname,"w",stdout);
	unsigned int start_seq=0;
	start_seq = atoi(argv[3]);

	parse_pcap_file( pcap_fname, res_vector, start_seq);
	print_vector( res_vector);
	res_vector.clear();
	return 0;
}

inline void print_vector(const std::vector<struct loss_and_thrpt> vec){
	unsigned int i=0;
	using namespace std;
	for(;i<vec.size();i++)
		printf("pkt_num fi: %u\tthroughput:%fMbps\n",vec[i].pkt_num,vec[i].thrpt);
}
