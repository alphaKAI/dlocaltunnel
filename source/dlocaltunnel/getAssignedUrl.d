module dlocaltunnel.getAssignedUrl;
import std.net.curl,
       std.string,
       std.conv,
       std.json;

enum localtunnelServer = "http://localtunnel.me/";

struct AssignedUrlInfo {
  string id,
         url;
  long port,
       max_conn_count;
}

import std.stdio;

AssignedUrlInfo getAssignedUrl(string assignedDomain = "") {
  AssignedUrlInfo aui;

  if (assignedDomain.empty) {
    assignedDomain = "?new";
  }

  string url = localtunnelServer ~ assignedDomain;
  string response = get(url).to!string;
  
  auto responseJson = parseJSON(response);
  
  foreach (k; __traits(allMembers, AssignedUrlInfo)) {
    if (k !in responseJson.object) {
      throw new Error("Invalid response from localtunnel server");
    }
  }

  aui.id   = responseJson.object["id"].str;
  aui.url  = responseJson.object["url"].str;
  aui.port = responseJson.object["port"].integer;
  aui.max_conn_count = responseJson.object["max_conn_count"].integer;

  return aui;
}

