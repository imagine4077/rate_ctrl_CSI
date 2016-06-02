#include <iostream>
#include <sys/socket.h>
#include <sstream>
#include <stdexcept>
#include <unistd.h>
#include <arpa/inet.h>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <cstring>

class AP{
	private:
		std::string serverIP,start_msg,end_msg,cmd,t;
		int round;
		unsigned int port;
		bool send_flag(std::string msg){
			bool ret = false;
			char buffer[128];
			strcpy(buffer,msg.c_str());
			int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			struct sockaddr_in serveradd;
			memset(&serveradd,0,sizeof(serveradd));
			serveradd.sin_family = AF_INET;
			serveradd.sin_addr.s_addr = inet_addr(serverIP.c_str());
			serveradd.sin_port = htons(port);
			int con_ret = connect(sock,(struct sockaddr*)&serveradd,sizeof(serveradd));
			std::cout <<"connect ret:"<< con_ret <<std::endl;
			while(0!=con_ret){
				con_ret = connect(sock,(struct sockaddr*)&serveradd,sizeof(serveradd));
				std::cout <<"connect ret:"<< con_ret <<std::endl;
			}
			if( write(sock,buffer,sizeof(buffer))) ret = true;
			close(sock);
			return ret;
		}
		std::string exec(const char* command){
			char buffer[128];
			std::string ret="";
			FILE* pipe = popen(command,"r");
			if(!pipe){
				std::cout << "popen() failed\n";
				throw std::runtime_error("popen() failed\n");
			}
			try{
				while(!feof(pipe)){
					if(fgets(buffer,128,pipe)!=NULL)
						ret += buffer;
				}
			}catch(...){
				std::cout << "exec error"<< std::endl;
				pclose(pipe);
				throw;
			}
			pclose(pipe);
			return ret;
		}
		void one_round(){
			if(send_flag(start_msg)){
		//	send_flag(start_msg);
				sleep(1);
				std::string output = exec(cmd.c_str());
				std::cout << output << std::endl;
			}
		}
	public:
		/** serverIP, iperf -t, times, port **/
		AP(std::string ip, std::string tmp_t, int r, unsigned int pt){
			serverIP = ip;
			t = tmp_t;
			round = r;
			port  = pt;
			//std::string iperf = "iperf -c "+ip+" -u -t "+tmp_t;
			//cmd = iperf;
			cmd = "./ap.sh "+ip+" "+tmp_t;
			std::cout << "cmd:" << cmd <<"\n";
			start_msg = "start";
			end_msg = "end";
			for(int i=0;i<round;i++){
				std::cout << "begin:round "<<i+1<<"/"<<round<< std::endl;
				one_round();
				std::cout << "done:round "<<i+1<<"/"<<round<< std::endl;
				sleep(10);
			}
		}
};

int str2int(std::string str){
	std::stringstream ss;
	ss << str;
	int ret;
	ss >> ret;
	return ret;
}

int main(int argc,char* argv[]){
	/** serverIP, iperf -t, times, port **/
	std::string ip(argv[1]);
	std::string t(argv[2]);
	std::string r(argv[3]);
	std::string pt(argv[4]);
	
	AP ap(ip,t,str2int(r),(unsigned int)str2int(pt));
}
