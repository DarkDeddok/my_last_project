terraform {
  required_version = ">= 0.12.21"
}

resource "null_resource" "storage_class" {
  count = var.context.use_longhorn ? 1:0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    EOT
  }
}

module "kubernetes" {
  source = "../../kubernetes"
  context = var.context
}

module "helm" {
  source = "../../helm"
  context = var.context
  cloud_provider = "helm"
}

module "database" {
  source = "../../infrastructure/database/helm"
  context = var.context
}

module "elasticsearch" {
  source = "../../infrastructure/elasticsearch/helm"
  context = var.context
}

module "kibana" {
  source = "../../infrastructure/kibana/helm"
  context = var.context
}

module "gremlin" {
  source                = "../../infrastructure/gremlin/helm"
  context               = var.context
  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
  }
}

module "monitoring" {
  source = "../../infrastructure/monitoring/helm"
  context = var.context

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    user = "${var.context.database.root.user}"
    password = "${var.context.database.root.password}"
  }

  redis = {
    host = "${module.redis.redis_host}"
    port = "${module.redis.redis_port}"
    password = "${module.redis.redis_password}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
  }

  kibana = {
    kibana_port = "${module.kibana.kibana_port}"
    kibana_host = "${module.kibana.kibana_host}"
    kibana_scheme = "${module.kibana.kibana_scheme}"
    kibana_path = "${module.kibana.kibana_path}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
  }

  cloud_provider = "helm"
}

module "redis" {
  source = "../../infrastructure/redis/helm"
  context = var.context
}

module "openiam-app" {
  source = "../../app"
  context = var.context

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    created_database = "${module.database.database_name}"
    flywayBaselineVersion = "${var.context.database.flywayBaselineVersion}"
    flywayCommand = "${var.context.database.flywayCommand}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
    kibana_full_url = "${module.kibana.kibana_scheme}://${module.kibana.kibana_host}:${module.kibana.kibana_port}${module.kibana.kibana_path}"
  }
  redis = {
    host = "${module.redis.redis_host}"
    port = "${module.redis.redis_port}"
    mode = "${module.redis.redis_mode}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
    cookie_name = "${var.context.rabbitmq.cookie_name}"
  }

  vault = {
    host = "${module.helm.vault_hostname}"
  }

  gremlin = {
    host = "${module.gremlin.host}"
    port = "${module.gremlin.port}"
  }

  cloud_provider = "helm"
}
