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

class RX{
	private:
		std::string cmd,start,end;
		std::string exec(const char* command){
			char buffer[128];
			std::string ret="";
			FILE* pipe = popen(command,"r");
			if(!pipe) throw std::runtime_error("popen() failed\n");
			try{
				while(!feof(pipe)){
					if(fgets(buffer,128,pipe)!=NULL)
						ret += buffer;
				}
			}catch(...){
				pclose(pipe);
				throw;
			}
			pclose(pipe);
			return ret;
		}
		void server(){
			int sock = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
			struct sockaddr_in server_addr;
			memset(&server_addr,0,sizeof(server_addr));
			server_addr.sin_family = AF_INET;
			//server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
			server_addr.sin_addr.s_addr = inet_addr("192.168.1.106");
			server_addr.sin_port = htons(1234);
			bind(sock,(struct sockaddr*)&server_addr,sizeof(server_addr));

			listen(sock,1);
			
			while(true){
				struct sockaddr cln_addr;
				socklen_t len = sizeof(cln_addr);
				int clnt_sock = accept(sock,&cln_addr,&len);
				char buffer[128];
				read(clnt_sock,buffer,sizeof(buffer));
				printf("%s\n",buffer);
				if(!strcmp(buffer,start.c_str())){
					std::string output = exec(cmd.c_str());
					std::cout << output << std::endl;
				}
				close(clnt_sock);
			}
		}
		
	public:
		RX(){
			start = "start";
			end = "end";
			cmd = "./iperf_csi.sh";
			server();
		}
};

int main(){
	RX rx;
	return 0;
}
