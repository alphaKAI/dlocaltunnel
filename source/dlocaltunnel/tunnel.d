module dlocaltunnel.tunnel;
import dlocaltunnel.getAssignedUrl;
import core.sync.mutex,
       core.thread;
import std.net.curl,
       std.socket,
       std.conv;

struct TunnelConn {
  string remoteHost;
  long remotePort;
  TcpSocket remoteConn,
            localConn;

  void close() {
    remoteConn.close;
    localConn.close;
  }
}

struct Tunnel {
  AssignedUrlInfo assignedUrlInfo;
}

class DTunnelConn {
  private {
    Tunnel tunnel;
    TunnelConn tunnelConn;
    long localPort;
    bool running = true;
  }

  this(string assignedDomain, long localPort) {
    tunnel.assignedUrlInfo = getAssignedUrl(assignedDomain);
    commonInitializer(localPort);
  }

  this(long localPort) {
    tunnel.assignedUrlInfo = getAssignedUrl;
    commonInitializer(localPort);
  }

  Thread startTunnel() {
    if (checkLocalPort is false) {
      throw new Error("Port of \"" ~ localPort.to!string ~ "\" is not accessible");
    }

    enum host = "localtunnel.me";

    tunnelConn.remoteHost = host;
    tunnelConn.remotePort = tunnel.assignedUrlInfo.port;

    Thread th = new Thread(() {
      while (running) {
        tunnelConn.remoteConn = new TcpSocket(new InternetAddress(tunnelConn.remoteHost, cast(ushort)tunnelConn.remotePort));
        tunnelConn.localConn  = new TcpSocket(new InternetAddress("localhost", cast(ushort)localPort));
         
        SyncConns(
          tunnelConn.remoteConn,
          tunnelConn.localConn
        );
        SyncConns(
          tunnelConn.localConn,
          tunnelConn.remoteConn
        );

        tunnelConn.close;
      }
    });
    th.start;

    return th;
  }

  void closeTunnel() {
    running = false;
  }

  @property getAssignedUrlInfo() {
    return tunnel.assignedUrlInfo;
  }

  private {
    void commonInitializer(long localPort) {
      this.localPort = localPort;
    }

    bool checkLocalPort() {
      try {
        new TcpSocket(new InternetAddress("localhost", cast(ushort)localPort));
      } catch {
        return false;
      }

      return true;
    }

    void SyncConns(
        Socket from,
        Socket to
      ) {

        char[1024] buf;

        auto rsize = from.receive(buf);
        char[] rbuf;
        if (rsize == 0) {
          return;
        } else if (rsize == -1) {
          throw new Error("recv");
        } else {
          rbuf = buf[0..rsize];
          to.send(rbuf);
        }
    }
  }

}
