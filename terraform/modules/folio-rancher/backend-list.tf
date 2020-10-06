data "http" "okapi-install" {
    url = "${var.ref_environment}/okapi-install.json"

    request_headers = {
        Accept = "application/json"
    }
}

locals {
  modules-list  = jsondecode(data.http.okapi-install.body)[*]["id"]
  modules-map   = {
    for name in local.modules-list : trimsuffix(regex("^\\D+-", name), "-") => regex("[[:digit:]]+.*$", name)
  }

}
