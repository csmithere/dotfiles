function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, "myanonamouse.net")) {
      return "PROXY 192.168.1.4:8118";
    }
    return "DIRECT";
  }
