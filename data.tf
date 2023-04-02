data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  local_ip_address = data.http.ip.response_body
}
