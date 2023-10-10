app_name = "test2021"

region = "us-west2"

replica_count = "3"

namespace = "default"

use_longhorn = false

mods = {

# used by rabbitmq to fetch the delayed plugin path
  software_repo = "https://github.com"

# below are the original sources
#  appscode = "https://charts.appscode.com/stable"
#  bitnami = "https://charts.bitnami.com/bitnami"
#  hashicorp = "https://helm.releases.hashicorp.com"
#  elasticsearch = "https://helm.elastic.co"
#  gradient = "https://github.com/Gradiant/bigdata-charts/releases/download/hbase-0.1.6/hbase-0.1.6.tgz"


# but in order to avoid outages, we pull from the cloned repository thatwe host
  appscode = "https://openiam.jfrog.io/artifactory/helm"
  bitnami = "https://openiam.jfrog.io/artifactory/helm"
  hashicorp = "https://openiam.jfrog.io/artifactory/helm"
  elasticsearch = "https://openiam.jfrog.io/artifactory/helm"
  gradient = "https://openiam.jfrog.io/artifactory/helm"
}

cluster = {
  aws = {
    cluster_endpoint_public_access = true
  }
}

autodeploy = {

    # if true, the openiam stack will deploy every time terraform is run
    openiam = true

    # if true, the openiam rproxy stack will deploy every time terraform is run
    rproxy = true

    # if true, the openiam vault stack will deploy every time terraform is run
    vault = false
}

cassandra = {
  password = "Password#51"
  persistenceSize = "5Gi"
  replicas = 1
}

javaOpts = {
  #applied to all images
  global = "-Dlogging.level.root=INFO -Dlogging.level.org.openiam=INFO -Dlogging.level.org.elasticsearch.client=ERROR"

  #app-specific
  ui = ""
  esb = ""
  idm = ""
  synchronization = ""
  groovy_manager = ""
  business_rule_manager = ""
  workflow = ""
  authmanager = ""
  emailmanager = ""
  devicemanager = ""
  sasmanager = ""
  reconciliation = ""
  connectors = {
      ldap = ""
      google = ""
      aws = ""
      freshdesk = ""
      linux = ""
      oracle_ebs = ""
      oracle = ""
      scim = ""
      script = ""
      salesforce = ""
      rexx = ""
      jdbc = ""
      saps4hana = ""
      freshservice = ""
      tableau = ""
      oracle_idcs = ""
      workday = ""
      adp = ""
      ipa = ""
      box = ""
      boomi = ""
      lastpass = ""
      kronos = ""
      thales = ""
      postgresql = ""
  }
}

replica_count_map = {
    ui = 1
    esb = 1
    idm = 1
    synchronization = 1
    groovy_manager = 1
    business_rule_manager = 1
    workflow = 1
    authmanager = 1
    emailmanager = 1
    devicemanager = 1
    sasmanager = 0
    rproxy = 1
    reconciliation = 1
    http_source_adapter = 1
    connectors = {
        ldap = 1
        google = 0
        aws = 0
        freshdesk = 0
        linux = 1
        oracle_ebs = 0
        oracle = 0
        scim = 1
        script = 1
        salesforce = 0
        rexx = 0
        jdbc = 1
        saps4hana = 0
        freshservice = 0
        tableau = 0
        oracle_idcs = 0
        workday = 0
        adp = 0
        ipa = 0
        box = 0
        boomi = 0
        lastpass = 0
        kronos = 0
        thales = 0
        postgresql = 0
    }
    rabbitmq = 1
}

rproxy = {
    https = {
        # rproxy by default uses https. you can set this to 1 to disable https
        disabled = "1"

        # SSL Protocols and Ciphers options. if not set, apache 2.4 defaults will be used.
        # For Example: disable everything except TLSv1.2 and allow only ciphers with high encryption:
        # protocol="-ALL -TLSv1 -TLSv1.1 +TLSv1.2"
        # cipherSuite="HIGH:!MEDIUM:!aNULL:!MD5:!RC4"
        protocol = ""
        cipherSuite = ""

        # if https uses non-default(443) port, specify full https host name for redirects from http to https.
        # for example:
        # host=https://node1.openiam.com:8001
        host = ""
    }

    loadBalancer = {
      ip = ""
    }

    proxyPassReverse = ""

    # extra apache configs
    apache = {
        extra = ""
    }

    # extra vhosts configs
    vhost = {
        extra = ""
    }

    # Apache mod_deflate compression ratio. Values from 0 to 9. By default is set to 6
    deflate = "6"

    # Content-Security-Policy headers enabled by default
    csp = "1"

    # Cross-Origin Resource Sharing enabled by default
    cors = "1"

    # If user hit for example: http://demo.openiamdemo.com/ redirect him to
    # http://demo.openiamdemo.com/selfservice/ by default, instead of showing error 404 (not found).
    defaultUri = "/selfservice/"

    # OPENIAM_DISABLE_CONFIGURE set to 1 by default. this allow to configure content provider on first access.
    # But after that, it is possible to set it to 0 to disable ability to configure content provider using /webconsole/setup.html url.
    disableConfigure = "0"

    # rproxy debug options. set any value for enable or keep empty for disable debug logging
    verbose = "0"

    debug = {
        base = "0"
        esb = "0"
        auth = "0"
    }

    # rproxy logging
    # By default /dev/stderr used for OPENIAM_RPROXY_ERROR_LOG and
    # /dev/stdout for OPENIAM_RPROXY_ACCESS_LOG. You can change that here,
    # for example use /dev/stdout for both error log and access log
    # or set access log to /dev/null and log only errors.
    # if not set, defaults used.
    #export error=/dev/stderr
    #export access=/dev/stdout
    log = {
        error = ""
        access = ""
    }

    aws = {
        # the ARN of the Certificate Manager
        # if this value is set, you MUST set rproxy.https.disabled to "1"
        certificateManagerARN = ""
    }
}

database = {
    # type of database.  Can be one of 'MariaDB', 'Postgres', 'Oracle', or 'MSSQL'
    type = "MariaDB"

    # flyway baseline version
    # set this to another value if you're migrating from a pre-4.2.0 version of OpenIAM
    flywayBaselineVersion = "2.3.0.0"

    # either 'migrate' or 'repair'
    flywayCommand = "migrate"

    # need this ability, just in case.  Some version of postgres require this
    jdbcIncludeSchemaInQueries = "false"
    hibernateIncludeSchemaInQueries = "false"

    # hibernate-specific propertyes
    hibernate = {
        # required for Oracle and MSSQL.  Ignored otherwise
        # For a complete list, see https://docs.jboss.org/hibernate/orm/3.5/javadocs/org/hibernate/dialect/package-summary.html
        # Example values:
        # org.hibernate.dialect.Oracle10gDialect ( the most common value for Oracle)
        # org.hibernate.dialect.SQLServer2008Dialect (the most common value for MSSQL)
        dialect = "org.hibernate.dialect.SQLServer2008Dialect"
    }

    # the master credentials into the database
    # if using AWS or GKE, do not use 'root' or 'master' as the username.  Use a strong password.
    root = {
        user = "openiamadmin2"
        password = "passwd00"
    }

    # the openiam user, password, and database names
    openiam = {
        user = "iamuser"
        password = "IAMUSER"
        database_name = "openiam"
        schema_name = "openiam"
    }

    # if using mariadb or postgres, setting this to '1' will deploy an empty mariadb or postgres image
    # enabling you to talk to the database within the same region
    # useful when your database is accessible only from within the kube cluster
    debugclient = {
        enabled = "0"
    }

    # the activiti user, password, and database names
    activiti = {
        user = "activiti"
        password = "ACTIVITI"
        database_name = "activiti"
        schema_name = "activiti"
    }

    # set only if your database is managed by you.
    # setting this when using AWS or GKE have no effect
    host = ""

    # arguments required for Oracle only
    # using them in a non-oracle context will have no effect
    oracle = {

        # required - this is the oracle SID
        # this must be a CAPITALCASE ALPHABETIC (A-Z) STRING
        sid = ""

        # required - ths is the timezone of the Oracle database
        timezone = ""
    }

    helm = {
        # set these ONLY if the database is external (not managed by Openiam)
        # and managed by you
        host = ""
        port = ""

        # number of replicas of the mariadb or postgres database, managed by OpenIAM, deployed in your private
        # k8 cluster
        replicas = "1"

        size = "100Gi"
    }

    google = {
        # Google Instance class for the database instance.
        # For Mysql, see https://cloud.google.com/sql/pricing#2nd-gen-pricing
        # For Postgres, see https://cloud.google.com/sql/pricing#pg-pricing
        # Note - for Postgres, using any of the provided tiers will NOT be enough, due to limitations to the number of concurrent connections
        #        see - https://cloud.google.com/sql/docs/postgres/quotas
        # If you're using Postgres, you will have to create a custom tier, and then use that as the value of this string.  See https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type#create
        instance_class = "db-g1-small"
    }

    # AWS Specific
    aws = {

        # The port where the RDS instance will be run
        port = "3306"

        # required.  See the 'Engine' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # we support mariadb, postgres, oracle
        #
        # Note - We do NOT currently support MSSQL in AWS RDS
        #
        # Note - we do NOT support or oracle se or oracle-se1.  They have a maximum version of Oracle 11, which
        # is not compatible with our version of flyway.  Also NOTE - oracle-ee has NOT been tested due to licencing limitations.  Use at your own risk
        # Thus - the only version tested version of Oracle in AWS that we fully support is oracle-se2.  Use oracle-ee at your own risk
        engine = "mariadb"

        # highly recommended. Instance class for the database instance.
        # See - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html - for a complete list.
        # if not specified, we will use a sensible default value, based on the database engine.  However, it is recommended to set this manually
        instance_class = "db.t3.medium"

        # See the 'EngineVersion' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # It is encouraged to leave this blank
        version = ""

        # If using mariadb, posrgres, or mssql, you MAY specify a value, but it is encouraged to leave this blank
        major_engine_version = ""

        # required for Oracle.  See the 'DBParameterGroupName' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # If using mariadb, posrgres, or mssql, you MAY specify a value, but it is encouraged to leave this blank
        family = ""

        # required for certain versions of Oracle (oracle-se1 and oracle-se2).  See the 'LicenseModel' parameter for the API
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # we default to licence-included where possible (all mssql versions, oracle-se1, oracle-se2)
        license_model = ""

        # Is this a mult-az Deployment?  See https://aws.amazon.com/rds/details/multi-az/
        multi_az = false

        # any additional parameters passed to the database instance upon creation.
        # see https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
        parameters = []

        # required  See the 'AllocatedStorage' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # The value of this will depend on the value of allocated_storage (as per the API)
        # we default to 20, as this is the minimum value that can be used for our default storage_type (gp2)
        allocated_storage = "20"

        # required.  See the 'StorageType' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        storage_type = "gp2"

        # optional.  See the 'BackupRetentionPeriod' parameter for the API:
        # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
        # a value of '0' disables backups
        # Note:  a non-zero value will resulut in terraform destroy failing.  terraform destroy will attempt to
        # delete the option group, which is associated with a database snapshop (which cannot be deleted)
        # Regardless, we recommend setting this to a value greater than "1".  We set it to "7", so that you can
        # backup data for up to a week.  We recommend setting this value to "0" when testing, and to a higher value
        # when deploying to production
        backup_retention_period = "0"
    }
}

redis = {
  password = "passwd00"

  aws = {
    # required.  See https://aws.amazon.com/elasticache/pricing/
    instance_class = "cache.t2.medium"
  }

  google = {
    # required.  Memory (in GB)
    memory = 1
  }

  # if using redis in AWS or GKE, you can set this to '1' to deploy an image with redis-client in the cluster.
  # useful when your redis is accessible only from within the kube cluster
  debugclient = {
      enabled = "0"
  }

  helm = {
    replicas = 1

    sentinel = {
      downAfterMilliseconds = 5000
      failoverTimeout = 5000
      enabled = true
    }
  }
}

elasticsearch = {
    aws = {
        # required.
        # https://aws.amazon.com/elasticsearch-service/pricing/
        instance_class = "t2.medium.elasticsearch"

        # see https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html#ebs_options
        # certain instance types (listed here:  https://aws.amazon.com/elasticsearch-service/pricing/) use ESB.  For these,
        # you MUST set this flag to true.  If your instance class uses SSD, and not EBS, then you MUST set this flag to false
        ebs_enabled = true

        # the volume size of the EBS, in GB.
        # only used if ebs_enabled is set to true
        ebs_volume_size = "10"
    }

    # use only when deploying to GKE or Local Kubernetes Cluster
    helm = {
        esJavaOpts = "-XshowSettings:vm -Xmx1536m -Xms1536m -Dlog4j2.formatMsgNoLookups=true"
        replicas = "1"
        storageSize = "100Gi"
        curate = {
          days = "1"
          maxIndexDays = "1"
          sizeGB = "10"
        }
        index = {
          days = "10"
          maxIndexDays = "1"
          sizeGB = "10"
          warnPhaseDays = "2"
          coldPhaseDays = "3"
        }

        authentication = {
          username = "elastic"
          password = "ChangeMeToSomethingMoreSecure123#51"
        }
    }
}

kibana = {

    # used only when deploying to helm (not AWS/GKE)
    helm = {
        replicas = "1"
        enabled = "true"
    }
}

metricbeat = {
    # used only when deploying to helm (not AWS/GKE)
    helm = {
        replicas = "1"
        enabled = "false"
    }
}

filebeat = {
    # used only when deploying to helm (not AWS/GKE)
    helm = {
        replicas = "1"
        enabled = "false"
    }
}

rabbitmq = {
    user = "openiam"
    password = "Password#51"
    cookie_name = "OpenIAMClusterCookie"
    jksKeyPassword = "passwd00"
    tls = {
        enabled = false
        failIfNoPeerCert = false
        sslOptionsVerify = "verify_none"
    }
    serviceType = "ClusterIP"
    memory = {
      memoryHighWatermark = "921MB"
      request = "1024Mi"
      limit = "1024Mi"
    }
}

logging = {
    level = {
        bash = "error"

        # for production use please change log level to warn or error. Debug will generate a lot of information.
        # possible values ERROR, WARN, INFO, DEBUG, or TRACE
        app = "INFO"
    }
}

kubernetes = {
    aws = {
        machine_type = "m4.2xlarge"
    }
    gke = {
        machine_type = "n1-standard-8"
    }
}

gremlin = {
    additionalJavaOpts = "-Xms512m -Xmx768m"
    aws = {
        machine_type = "db.t3.medium"
        replicas = "1"
    }
    helm = {
        replicas = "1"
    }
    gke = {
        replicas = "1"
        bigtable = {
            instances = "1"
        }
    }
}

# vault
vault = {
    replicas = "1"

    #set this to 'true' if you're migrating from a pre-4.2.1 version.
    migrate = "false"

    # consul parameters, if consul is enabled
    consul = {

      # generate using `kubectl create secret generic consul-gossip-encryption-key --from-literal=key=$(consul keygen)`
      gossipEncryption = {
        secretName = ""
        secretKey = ""
      }

      storage = "100Gi"
    }
    cert = {
        # Vault Certificate Country Code
        country = "US"

        # Vault Certificate State Code
        state = "Test"

        # Vault Certificate Locality Code
        locality = "Test"

        # Vault Certificate Organization
        organization = "Test"

        # Vault Certificate Organization
        organizationunit = "Test"
    }
    vaultKeyPassword = "passwd00"
    secrets = {
        javaKeystorePassword = "changeit"
        jks = {
            password = "openiamKeyStorePassword"
            keyPassword = "openiamMasterKey"
            cookieKeyPassword = "openiamCookieKey"
            commonKeyPassword = "openiamCommonKey"
        }
    }
}

stash = {
  enabled = true
  replicas = 1
  # set to true if this is an communty stash version (which you must create a license for)
  community = true
}
