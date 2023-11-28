provider "google" {
  access_token = var.access_token
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "gke_${var.project}_${var.region}_${var.cluster_name}"
}

resource "kubernetes_ingress_v1" "awx_ingress" {

  metadata {
    name        = "awx-ingress"
    namespace   = "awx"
  }
   spec {
      rule {
        http {
         path {
           backend {
             service {
               name = "awx-service"
               port {
                 number = 80
               }
             }
           }
        }
      }
    }
  }
  wait_for_load_balancer = true
}

data "external" "pull_password" {
  program = ["../awx-operator/get_admin_password.sh"]
}

# Display AWX url, username and password
output "load_balancer_ip" {
  value = "############################################## \nLogin to AWX with below details \nURL: http://${kubernetes_ingress_v1.awx_ingress.status.0.load_balancer.0.ingress.0.ip} \nUsername: admin \nPassword: ${data.external.pull_password.result["password"]} \n##############################################"
}