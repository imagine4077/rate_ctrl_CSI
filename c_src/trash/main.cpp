#include "measure_util.h"
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <vector>

int main(int argc, char* argv[]){
	using std::deque;
	using std::cout;
	using std::endl;

	if(argc!=2){
		printf("wrong argument\n");
		exit(1);
	}
	char* pcap_fname = argv[1];
	char* output_fname = (char*)malloc(sizeof(pcap_fname)+10);
	std::vector<struct loss_and_thrpt> res_vector;
	strcpy(output_fname, pcap_fname);
	strcat(output_fname,"._out");
	printf("outfile: %s\n",output_fname);
	freopen(output_fname,"w",stdout);

	parse_pcap_file( pcap_fname, res_vector);

}
