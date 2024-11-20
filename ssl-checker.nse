local nmap = require "nmap"
local sslcert = require "sslcert"

description = [[
Attempts to connect to open TCP ports to determine if they are running SSL/TLS.
]]

author = "https://github.com/xiw1ll"

license = "Same as Nmap--See https://nmap.org/book/man-legal.html"

categories = {"default", "discovery", "safe"}

portrule = function(host, port)
  if port.protocol ~= "tcp" or port.state ~= "open" then
    return false
  end
  if port.version and port.version.service_tunnel == "ssl" then
    return false
  end
  return true
end

action = function(host, port)
  -- Attempt to retrieve the SSL/TLS certificate
  local status, cert = sslcert.getCertificate(host, port)
  if status and cert then
    port.version.service_tunnel = "ssl"
    nmap.set_port_version(host, port, "softmatched")
  else
    return nil -- No output if SSL/TLS is not detected
  end
end
