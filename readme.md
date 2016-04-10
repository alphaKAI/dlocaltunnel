#DLocalTunnel
D language version of [http://localtunnel.me](http://localtunnel.me) client  
Inspired by [gotunnelme](https://github.com/NoahShen/gotunnelme)  

#Usage
Here is sample of this library:  

```D:
import dlocaltunnel.tunnel;
import core.thread;
import std.stdio;

void main() {
  //First way:
  long localPort = YourLocalPortToFoward;
  DTunnelConn dtc = new DTunnelConn(localPort);
  /*
    If you don't specify subdomain, the url of will be published is randomized.
    Ex: https://XXXXX.localtunnel.me
    
    If you want fix the url, you should use second way
  */
  //Second way:
  DTunnelConn dtc = new DTunnelConn("subdomainPrefix", localPort);
  /*
    As a result, the url of will be published is
      subdomainPrefix.localtunnel.me
  */

  //Common: Start tunneling as separate thread(you should wait the thread by join function)
  Thread tunnelThread = dtc.startTunnel;

  //Print the url and port
  dtc.getAssignedUrlInfo.writeln;

  writeln("Started tunneling!");

  //Wait for the thread
  tunnelThread.join;
}
```

#License
This software is released under the MIT License  
[The MIT License](https://opensource.org/licenses/MIT)
